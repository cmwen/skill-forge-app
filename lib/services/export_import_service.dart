import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Service for exporting and importing app data.
class ExportImportService {
  final DatabaseHelper _db;

  ExportImportService(this._db);

  // ============================================================
  // Export
  // ============================================================

  /// Export all data as JSON
  Future<String> exportAsJson() async {
    final goals = await _db.getAllGoals();
    final allDecks = <Deck>[];
    final allCards = <Flashcard>[];
    final allSessions = <StudySession>[];

    // Gather all data
    for (final goal in goals) {
      final decks = await _db.getDecksForGoal(goal.id);
      allDecks.addAll(decks);

      for (final deck in decks) {
        final cards = await _db.getFlashcardsForDeck(deck.id);
        allCards.addAll(cards);
      }

      final sessions = await _db.getStudySessionsForGoal(goal.id);
      allSessions.addAll(sessions);
    }

    // Create export data structure
    final exportData = {
      'version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toMap()).toList(),
      'decks': allDecks.map((d) => d.toMap()).toList(),
      'flashcards': allCards.map((c) => c.toMap()).toList(),
      'study_sessions': allSessions.map((s) => s.toMap()).toList(),
    };

    return JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Export all data as CSV (cards only, Anki/Quizlet compatible)
  Future<String> exportAsCsv() async {
    final goals = await _db.getAllGoals();
    final csvLines = <String>['Front,Back,Deck,Goal'];

    for (final goal in goals) {
      final decks = await _db.getDecksForGoal(goal.id);

      for (final deck in decks) {
        final cards = await _db.getFlashcardsForDeck(deck.id);

        for (final card in cards) {
          // Escape commas and quotes in CSV format
          final front = _escapeCsv(card.front);
          final back = _escapeCsv(card.back);
          final deckName = _escapeCsv(deck.name);
          final goalName = _escapeCsv(goal.name);

          csvLines.add('$front,$back,$deckName,$goalName');
        }
      }
    }

    return csvLines.join('\n');
  }

  String _escapeCsv(String value) {
    // If contains comma, quote, or newline, wrap in quotes and escape quotes
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Save export to file and share
  Future<void> exportAndShare({required ExportFormat format}) async {
    final String content;
    final String filename;

    switch (format) {
      case ExportFormat.json:
        content = await exportAsJson();
        filename = 'skill_forge_backup_${_getTimestamp()}.json';
        break;
      case ExportFormat.csv:
        content = await exportAsCsv();
        filename = 'skill_forge_cards_${_getTimestamp()}.csv';
        break;
    }

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsString(content);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], subject: 'Skill Forge Export');
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  /// Export a single deck as JSON
  Future<String> exportDeckAsJson(String deckId) async {
    final deck = await _db.getDeck(deckId);
    if (deck == null) throw Exception('Deck not found');

    final cards = await _db.getFlashcardsForDeck(deckId);

    final exportData = {
      'version': '1.0',
      'type': 'deck_export',
      'exported_at': DateTime.now().toIso8601String(),
      'deck': deck.toMap(),
      'flashcards': cards.map((c) => c.toMap()).toList(),
    };

    return JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Export a single deck as CSV
  Future<String> exportDeckAsCsv(String deckId) async {
    final deck = await _db.getDeck(deckId);
    if (deck == null) throw Exception('Deck not found');

    final cards = await _db.getFlashcardsForDeck(deckId);
    final csvLines = <String>['Front,Back,Notes'];

    for (final card in cards) {
      final front = _escapeCsv(card.front);
      final back = _escapeCsv(card.back);
      final notes = _escapeCsv(card.notes ?? '');
      csvLines.add('$front,$back,$notes');
    }

    return csvLines.join('\n');
  }

  /// Export a single deck and share
  Future<void> exportDeckAndShare({
    required String deckId,
    required ExportFormat format,
  }) async {
    final deck = await _db.getDeck(deckId);
    if (deck == null) throw Exception('Deck not found');

    final String content;
    final String filename;

    final safeDeckName = deck.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    switch (format) {
      case ExportFormat.json:
        content = await exportDeckAsJson(deckId);
        filename = '${safeDeckName}_${_getTimestamp()}.json';
        break;
      case ExportFormat.csv:
        content = await exportDeckAsCsv(deckId);
        filename = '${safeDeckName}_${_getTimestamp()}.csv';
        break;
    }

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsString(content);

    // Share the file
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Skill Forge - ${deck.name}');
  }

  /// Export a single goal with all its decks and cards
  Future<String> exportGoalAsJson(String goalId) async {
    final goal = await _db.getGoal(goalId);
    if (goal == null) throw Exception('Goal not found');

    final decks = await _db.getDecksForGoal(goalId);
    final allCards = <Flashcard>[];
    final sessions = await _db.getStudySessionsForGoal(goalId);

    for (final deck in decks) {
      final cards = await _db.getFlashcardsForDeck(deck.id);
      allCards.addAll(cards);
    }

    final exportData = {
      'version': '1.0',
      'type': 'goal_export',
      'exported_at': DateTime.now().toIso8601String(),
      'goal': goal.toMap(),
      'decks': decks.map((d) => d.toMap()).toList(),
      'flashcards': allCards.map((c) => c.toMap()).toList(),
      'study_sessions': sessions.map((s) => s.toMap()).toList(),
    };

    return JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Export a single goal and share
  Future<void> exportGoalAndShare(String goalId) async {
    final goal = await _db.getGoal(goalId);
    if (goal == null) throw Exception('Goal not found');

    final content = await exportGoalAsJson(goalId);
    final safeGoalName = goal.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filename = '${safeGoalName}_${_getTimestamp()}.json';

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsString(content);

    // Share the file
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Skill Forge - ${goal.name}');
  }

  // ============================================================
  // Import
  // ============================================================

  /// Import data from JSON string
  Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as String?;
      if (version != '1.0') {
        return ImportResult(
          success: false,
          message: 'Unsupported export version: $version',
        );
      }

      int goalsImported = 0;
      int decksImported = 0;
      int cardsImported = 0;
      int sessionsImported = 0;

      // Import goals
      final goals =
          (data['goals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final goalMap in goals) {
        final goal = LearningGoal.fromMap(goalMap);
        await _db.insertGoal(goal);
        goalsImported++;
      }

      // Import decks
      final decks =
          (data['decks'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final deckMap in decks) {
        final deck = Deck.fromMap(deckMap);
        await _db.insertDeck(deck);
        decksImported++;
      }

      // Import flashcards
      final cards =
          (data['flashcards'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final cardMap in cards) {
        final card = Flashcard.fromMap(cardMap);
        await _db.insertFlashcard(card);
        cardsImported++;
      }

      // Import study sessions
      final sessions =
          (data['study_sessions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final sessionMap in sessions) {
        final session = StudySession.fromMap(sessionMap);
        await _db.insertStudySession(session);
        sessionsImported++;
      }

      return ImportResult(
        success: true,
        message:
            'Imported $goalsImported goals, $decksImported decks, $cardsImported cards, $sessionsImported sessions',
        goalsImported: goalsImported,
        decksImported: decksImported,
        cardsImported: cardsImported,
        sessionsImported: sessionsImported,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'Import failed: $e');
    }
  }

  /// Import cards from CSV
  Future<ImportResult> importFromCsv(
    String csvString, {
    required String goalId,
    required String deckName,
  }) async {
    try {
      // Create or get deck
      final deck = await _db.insertDeck(
        Deck.create(goalId: goalId, name: deckName, source: 'CSV Import'),
      );

      final lines = csvString.split('\n');
      int cardsImported = 0;

      // Skip header if present
      int startIndex = 0;
      if (lines.isNotEmpty && lines[0].toLowerCase().contains('front')) {
        startIndex = 1;
      }

      for (int i = startIndex; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final parts = _parseCsvLine(line);
        if (parts.length >= 2) {
          final card = Flashcard.create(
            deckId: deck.id,
            front: parts[0],
            back: parts[1],
          );
          await _db.insertFlashcard(card);
          cardsImported++;
        }
      }

      return ImportResult(
        success: true,
        message: 'Imported $cardsImported cards into "$deckName"',
        cardsImported: cardsImported,
      );
    } catch (e) {
      return ImportResult(success: false, message: 'CSV import failed: $e');
    }
  }

  List<String> _parseCsvLine(String line) {
    final parts = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        parts.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    parts.add(buffer.toString().trim());
    return parts;
  }
}

/// Export format options
enum ExportFormat { json, csv }

/// Result of an import operation
class ImportResult {
  final bool success;
  final String message;
  final int goalsImported;
  final int decksImported;
  final int cardsImported;
  final int sessionsImported;

  ImportResult({
    required this.success,
    required this.message,
    this.goalsImported = 0,
    this.decksImported = 0,
    this.cardsImported = 0,
    this.sessionsImported = 0,
  });
}
