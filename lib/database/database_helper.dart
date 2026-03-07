import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Database helper for Skill Forge.
///
/// Provides CRUD operations for learning goals, decks, flashcards,
/// and study sessions using SQLite.
///
/// ## Usage
///
/// ```dart
/// final db = DatabaseHelper();
/// await db.initialize();
///
/// // Create a goal
/// final goal = LearningGoal.create(name: 'Spanish', icon: '🇪🇸');
/// await db.insertGoal(goal);
///
/// // Query goals
/// final goals = await db.getAllGoals();
/// ```
class DatabaseHelper {
  static const String _defaultDatabaseName = 'skill_forge.db';
  static const int _databaseVersion = 2;

  /// Custom database name for testing
  final String _databaseName;

  /// Whether to use in-memory database (for testing)
  final bool _inMemory;

  Database? _database;

  /// Creates a DatabaseHelper instance
  ///
  /// [databaseName] - Custom database name (for testing)
  /// [inMemory] - Use in-memory database (for testing)
  DatabaseHelper({String? databaseName, bool inMemory = false})
    : _databaseName = databaseName ?? _defaultDatabaseName,
      _inMemory = inMemory;

  /// Whether the database is initialized
  bool get isInitialized => _database != null;

  /// Initialize the database
  Future<void> initialize() async {
    if (_database != null) return;

    final String path;
    if (_inMemory) {
      path = inMemoryDatabasePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _databaseName);
    }

    try {
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Verify that critical tables exist
      await _verifySchema();
    } catch (e) {
      // If database is corrupted, delete and recreate
      try {
        if (!_inMemory) {
          await deleteDatabase(path);
        }
        _database = await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Verify that all critical tables exist
  Future<void> _verifySchema() async {
    final tables = ['learning_goals', 'decks', 'flashcards', 'study_sessions'];

    for (final table in tables) {
      try {
        await db.query(table, limit: 1);
      } catch (e) {
        // Table doesn't exist, run onCreate to create it
        await _onCreate(db, _databaseVersion);
        break;
      }
    }
  }

  /// Get the database instance
  Database get db {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Learning Goals table
    await db.execute('''
      CREATE TABLE learning_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT NOT NULL,
        target_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_studied_at TEXT,
        is_archived INTEGER NOT NULL DEFAULT 0,
        total_study_time_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Decks table
    await db.execute('''
      CREATE TABLE decks (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_studied_at TEXT,
        total_study_time_seconds INTEGER NOT NULL DEFAULT 0,
        source TEXT,
        FOREIGN KEY (goal_id) REFERENCES learning_goals (id) ON DELETE CASCADE
      )
    ''');

    // Flashcards table
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        deck_id TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_reviewed_at TEXT,
        next_review_at TEXT,
        review_count INTEGER NOT NULL DEFAULT 0,
        correct_count INTEGER NOT NULL DEFAULT 0,
        mastery_level INTEGER NOT NULL DEFAULT 0,
        interval_days REAL NOT NULL DEFAULT 1.0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');

    // Study Sessions table
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        goal_id TEXT NOT NULL,
        deck_id TEXT,
        session_type TEXT NOT NULL,
        started_at TEXT NOT NULL,
        ended_at TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        cards_reviewed INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        avg_time_per_card REAL NOT NULL,
        FOREIGN KEY (goal_id) REFERENCES learning_goals (id) ON DELETE CASCADE,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE SET NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute('CREATE INDEX idx_decks_goal_id ON decks (goal_id)');
    await db.execute(
      'CREATE INDEX idx_flashcards_deck_id ON flashcards (deck_id)',
    );
    await db.execute(
      'CREATE INDEX idx_flashcards_next_review ON flashcards (next_review_at)',
    );
    await db.execute(
      'CREATE INDEX idx_study_sessions_goal_id ON study_sessions (goal_id)',
    );
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to 2: Ensure all tables and columns exist
    if (oldVersion < 2) {
      try {
        // Add is_archived column to learning_goals if it doesn't exist
        await db.execute(
          'ALTER TABLE learning_goals ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0',
        );
      } catch (e) {
        // Column might already exist, which is fine
        if (!e.toString().contains('duplicate column name')) {
          rethrow;
        }
      }

      // Create study_sessions table if it doesn't exist
      try {
        await db.execute('''
          CREATE TABLE study_sessions (
            id TEXT PRIMARY KEY,
            goal_id TEXT NOT NULL,
            deck_id TEXT,
            session_type TEXT NOT NULL,
            started_at TEXT NOT NULL,
            ended_at TEXT NOT NULL,
            duration_seconds INTEGER NOT NULL,
            cards_reviewed INTEGER NOT NULL,
            correct_answers INTEGER NOT NULL,
            avg_time_per_card REAL NOT NULL,
            FOREIGN KEY (goal_id) REFERENCES learning_goals (id) ON DELETE CASCADE,
            FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE SET NULL
          )
        ''');
      } catch (e) {
        // Table might already exist, which is fine
        if (!e.toString().contains('already exists')) {
          rethrow;
        }
      }

      // Create indexes if they don't exist
      try {
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_study_sessions_goal_id ON study_sessions (goal_id)',
        );
      } catch (e) {
        // Index might already exist, which is fine
      }
    }
  }

  /// Close the database
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  // ============================================================
  // Learning Goal Operations
  // ============================================================

  /// Insert a new learning goal
  Future<void> insertGoal(LearningGoal goal) async {
    await db.insert('learning_goals', goal.toMap());
  }

  /// Update an existing learning goal
  Future<void> updateGoal(LearningGoal goal) async {
    await db.update(
      'learning_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  /// Delete a learning goal (cascades to decks and cards)
  Future<void> deleteGoal(String goalId) async {
    await db.delete('learning_goals', where: 'id = ?', whereArgs: [goalId]);
  }

  /// Get all learning goals
  Future<List<LearningGoal>> getAllGoals({bool includeArchived = false}) async {
    final List<Map<String, dynamic>> maps;
    if (includeArchived) {
      maps = await db.query('learning_goals', orderBy: 'updated_at DESC');
    } else {
      maps = await db.query(
        'learning_goals',
        where: 'is_archived = ?',
        whereArgs: [0],
        orderBy: 'updated_at DESC',
      );
    }
    return maps.map((m) => LearningGoal.fromMap(m)).toList();
  }

  /// Get a single learning goal by ID
  Future<LearningGoal?> getGoal(String goalId) async {
    final maps = await db.query(
      'learning_goals',
      where: 'id = ?',
      whereArgs: [goalId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return LearningGoal.fromMap(maps.first);
  }

  // ============================================================
  // Deck Operations
  // ============================================================

  /// Insert a new deck
  Future<Deck> insertDeck(Deck deck) async {
    await db.insert('decks', deck.toMap());
    return deck;
  }

  /// Update an existing deck
  Future<void> updateDeck(Deck deck) async {
    await db.update(
      'decks',
      deck.toMap(),
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  /// Delete a deck (cascades to flashcards)
  Future<void> deleteDeck(String deckId) async {
    await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
  }

  /// Get all decks for a goal
  Future<List<Deck>> getDecksForGoal(String goalId) async {
    final maps = await db.query(
      'decks',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((m) => Deck.fromMap(m)).toList();
  }

  /// Get a single deck by ID
  Future<Deck?> getDeck(String deckId) async {
    final maps = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Deck.fromMap(maps.first);
  }

  /// Get deck count for a goal
  Future<int> getDeckCountForGoal(String goalId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM decks WHERE goal_id = ?',
      [goalId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // Flashcard Operations
  // ============================================================

  /// Insert a new flashcard
  Future<void> insertFlashcard(Flashcard card) async {
    await db.insert('flashcards', card.toMap());
  }

  /// Insert multiple flashcards in a batch
  Future<void> insertFlashcards(List<Flashcard> cards) async {
    final batch = db.batch();
    for (final card in cards) {
      batch.insert('flashcards', card.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Update an existing flashcard
  Future<void> updateFlashcard(Flashcard card) async {
    await db.update(
      'flashcards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  /// Delete a flashcard
  Future<void> deleteFlashcard(String cardId) async {
    await db.delete('flashcards', where: 'id = ?', whereArgs: [cardId]);
  }

  /// Get all flashcards for a deck
  Future<List<Flashcard>> getFlashcardsForDeck(String deckId) async {
    final maps = await db.query(
      'flashcards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
      orderBy: 'created_at ASC',
    );
    return maps.map((m) => Flashcard.fromMap(m)).toList();
  }

  /// Get due flashcards for a deck (for spaced repetition)
  Future<List<Flashcard>> getDueFlashcardsForDeck(String deckId) async {
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'flashcards',
      where: 'deck_id = ? AND (next_review_at IS NULL OR next_review_at <= ?)',
      whereArgs: [deckId, now],
      orderBy: 'next_review_at ASC',
    );
    return maps.map((m) => Flashcard.fromMap(m)).toList();
  }

  /// Get a single flashcard by ID
  Future<Flashcard?> getFlashcard(String cardId) async {
    final maps = await db.query(
      'flashcards',
      where: 'id = ?',
      whereArgs: [cardId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Flashcard.fromMap(maps.first);
  }

  /// Get card count for a deck
  Future<int> getCardCountForDeck(String deckId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flashcards WHERE deck_id = ?',
      [deckId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get mastered card count for a deck
  Future<int> getMasteredCardCountForDeck(String deckId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM flashcards WHERE deck_id = ? AND mastery_level >= 80',
      [deckId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total card count for a goal (across all decks)
  Future<int> getCardCountForGoal(String goalId) async {
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM flashcards f 
      JOIN decks d ON f.deck_id = d.id 
      WHERE d.goal_id = ?
    ''',
      [goalId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get mastered card count for a goal
  Future<int> getMasteredCardCountForGoal(String goalId) async {
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count 
      FROM flashcards f 
      JOIN decks d ON f.deck_id = d.id 
      WHERE d.goal_id = ? AND f.mastery_level >= 80
    ''',
      [goalId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // Study Session Operations
  // ============================================================

  /// Insert a new study session
  Future<void> insertStudySession(StudySession session) async {
    await db.insert('study_sessions', session.toMap());
  }

  /// Get all study sessions for a goal
  Future<List<StudySession>> getStudySessionsForGoal(String goalId) async {
    final maps = await db.query(
      'study_sessions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'started_at DESC',
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  /// Get recent study sessions
  Future<List<StudySession>> getRecentStudySessions({int limit = 10}) async {
    final maps = await db.query(
      'study_sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return maps.map((m) => StudySession.fromMap(m)).toList();
  }

  /// Get total study time for a goal in seconds
  Future<int> getTotalStudyTimeForGoal(String goalId) async {
    final result = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM study_sessions WHERE goal_id = ?',
      [goalId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total study time today in seconds
  Future<int> getTodayStudyTime() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final result = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM study_sessions WHERE started_at >= ?',
      [startOfDay.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get total study time this week in seconds
  Future<int> getThisWeekStudyTime() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final result = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM study_sessions WHERE started_at >= ?',
      [startOfDay.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ============================================================
  // Statistics & Aggregations
  // ============================================================

  /// Get overall statistics
  Future<Map<String, dynamic>> getOverallStats() async {
    final totalGoals =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM learning_goals WHERE is_archived = 0',
          ),
        ) ??
        0;

    final totalCards =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM flashcards'),
        ) ??
        0;

    final masteredCards =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM flashcards WHERE mastery_level >= 80',
          ),
        ) ??
        0;

    final totalStudyTime =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT SUM(duration_seconds) FROM study_sessions'),
        ) ??
        0;

    return {
      'total_goals': totalGoals,
      'total_cards': totalCards,
      'mastered_cards': masteredCards,
      'total_study_time_seconds': totalStudyTime,
    };
  }
}
