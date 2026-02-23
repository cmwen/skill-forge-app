import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Provides state management for learning goals.
///
/// This provider manages the list of learning goals and provides
/// CRUD operations with automatic UI updates.
///
/// ## Usage
///
/// ```dart
/// // In a widget
/// final goalsProvider = context.watch<GoalsProvider>();
/// final goals = goalsProvider.goals;
///
/// // Create a new goal
/// await goalsProvider.createGoal(
///   name: 'Spanish for Travel',
///   icon: '🇪🇸',
/// );
/// ```
class GoalsProvider extends ChangeNotifier {
  final DatabaseHelper _db;

  /// List of active (non-archived) learning goals
  List<LearningGoal> _goals = [];

  /// List of archived learning goals
  List<LearningGoal> _archivedGoals = [];

  /// Whether goals are currently loading
  bool _isLoading = false;

  /// Error message if something went wrong
  String? _error;

  /// Statistics for each goal (deck count, card count, mastered count)
  final Map<String, GoalStats> _goalStats = {};

  GoalsProvider(this._db);

  // ============================================================
  // Getters
  // ============================================================

  /// Active learning goals
  List<LearningGoal> get goals => List.unmodifiable(_goals);

  /// Archived learning goals
  List<LearningGoal> get archivedGoals => List.unmodifiable(_archivedGoals);

  /// Whether goals are loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Get stats for a specific goal
  GoalStats? getStatsForGoal(String goalId) => _goalStats[goalId];

  // ============================================================
  // Load Operations
  // ============================================================

  /// Load all goals from the database
  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _db.getAllGoals(includeArchived: false);
      _archivedGoals = await _db.getAllGoals(includeArchived: true);
      _archivedGoals = _archivedGoals.where((g) => g.isArchived).toList();

      // Load stats for each goal
      await _loadGoalStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load goals: $e';
      notifyListeners();
    }
  }

  /// Load statistics for all goals
  Future<void> _loadGoalStats() async {
    _goalStats.clear();
    for (final goal in [..._goals, ..._archivedGoals]) {
      final deckCount = await _db.getDeckCountForGoal(goal.id);
      final cardCount = await _db.getCardCountForGoal(goal.id);
      final masteredCount = await _db.getMasteredCardCountForGoal(goal.id);
      final totalStudyTime = await _db.getTotalStudyTimeForGoal(goal.id);

      _goalStats[goal.id] = GoalStats(
        deckCount: deckCount,
        cardCount: cardCount,
        masteredCount: masteredCount,
        totalStudyTimeSeconds: totalStudyTime,
      );
    }
  }

  /// Refresh stats for a specific goal
  Future<void> refreshGoalStats(String goalId) async {
    final deckCount = await _db.getDeckCountForGoal(goalId);
    final cardCount = await _db.getCardCountForGoal(goalId);
    final masteredCount = await _db.getMasteredCardCountForGoal(goalId);
    final totalStudyTime = await _db.getTotalStudyTimeForGoal(goalId);

    _goalStats[goalId] = GoalStats(
      deckCount: deckCount,
      cardCount: cardCount,
      masteredCount: masteredCount,
      totalStudyTimeSeconds: totalStudyTime,
    );
    notifyListeners();
  }

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Create a new learning goal
  Future<LearningGoal> createGoal({
    required String name,
    String? description,
    String icon = '📚',
    DateTime? targetDate,
  }) async {
    final goal = LearningGoal.create(
      name: name,
      description: description,
      icon: icon,
      targetDate: targetDate,
    );

    await _db.insertGoal(goal);
    _goals.insert(0, goal);
    _goalStats[goal.id] = const GoalStats(
      deckCount: 0,
      cardCount: 0,
      masteredCount: 0,
      totalStudyTimeSeconds: 0,
    );
    notifyListeners();

    return goal;
  }

  /// Update an existing learning goal
  Future<void> updateGoal(LearningGoal goal) async {
    final updatedGoal = goal.copyWith(updatedAt: DateTime.now());
    await _db.updateGoal(updatedGoal);

    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _goals[index] = updatedGoal;
    } else {
      final archivedIndex = _archivedGoals.indexWhere((g) => g.id == goal.id);
      if (archivedIndex >= 0) {
        _archivedGoals[archivedIndex] = updatedGoal;
      }
    }

    notifyListeners();
  }

  /// Archive a learning goal
  Future<void> archiveGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) return;

    final goal = _goals[index];
    final archivedGoal = goal.copyWith(isArchived: true);

    await _db.updateGoal(archivedGoal);

    _goals.removeAt(index);
    _archivedGoals.insert(0, archivedGoal);
    notifyListeners();
  }

  /// Unarchive a learning goal
  Future<void> unarchiveGoal(String goalId) async {
    final index = _archivedGoals.indexWhere((g) => g.id == goalId);
    if (index < 0) return;

    final goal = _archivedGoals[index];
    final unarchivedGoal = goal.copyWith(isArchived: false);

    await _db.updateGoal(unarchivedGoal);

    _archivedGoals.removeAt(index);
    _goals.insert(0, unarchivedGoal);
    notifyListeners();
  }

  /// Delete a learning goal permanently
  Future<void> deleteGoal(String goalId) async {
    await _db.deleteGoal(goalId);

    _goals.removeWhere((g) => g.id == goalId);
    _archivedGoals.removeWhere((g) => g.id == goalId);
    _goalStats.remove(goalId);
    notifyListeners();
  }

  /// Update last studied timestamp for a goal
  Future<void> markGoalStudied(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) return;

    final goal = _goals[index];
    final updatedGoal = goal.copyWith(lastStudiedAt: DateTime.now());

    await _db.updateGoal(updatedGoal);
    _goals[index] = updatedGoal;
    notifyListeners();
  }

  /// Get a goal by ID
  LearningGoal? getGoalById(String goalId) {
    return _goals.cast<LearningGoal?>().firstWhere(
      (g) => g?.id == goalId,
      orElse: () => _archivedGoals.cast<LearningGoal?>().firstWhere(
        (g) => g?.id == goalId,
        orElse: () => null,
      ),
    );
  }
}

/// Statistics for a learning goal
class GoalStats {
  final int deckCount;
  final int cardCount;
  final int masteredCount;
  final int totalStudyTimeSeconds;

  const GoalStats({
    required this.deckCount,
    required this.cardCount,
    required this.masteredCount,
    this.totalStudyTimeSeconds = 0,
  });

  /// Progress percentage (0-100)
  double get progressPercent {
    if (cardCount == 0) return 0.0;
    return (masteredCount / cardCount) * 100;
  }
}
