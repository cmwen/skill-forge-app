import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Provides state management for study sessions and progress tracking.
class StudyProvider extends ChangeNotifier {
  final DatabaseHelper _db;

  /// Current study session in progress
  StudySession? _currentSession;

  /// Start time of current session
  DateTime? _sessionStartTime;

  /// Current goal ID being studied
  String? _currentGoalId;

  /// Current deck ID being studied
  String? _currentDeckId;

  /// Session type
  StudySessionType _sessionType = StudySessionType.flashcards;

  /// Cards reviewed in current session
  int _cardsReviewed = 0;

  /// Correct answers in current session
  int _correctAnswers = 0;

  /// Recent study sessions
  List<StudySession> _recentSessions = [];

  /// Overall statistics
  Map<String, dynamic> _overallStats = {};

  StudyProvider(this._db);

  // ============================================================
  // Getters
  // ============================================================

  /// Whether a study session is in progress
  bool get isSessionActive => _sessionStartTime != null;

  /// Current goal ID
  String? get currentGoalId => _currentGoalId;

  /// Current deck ID
  String? get currentDeckId => _currentDeckId;

  /// Cards reviewed count
  int get cardsReviewed => _cardsReviewed;

  /// Correct answers count
  int get correctAnswers => _correctAnswers;

  /// Current accuracy percentage
  double get currentAccuracy {
    if (_cardsReviewed == 0) return 0.0;
    return (_correctAnswers / _cardsReviewed) * 100;
  }

  /// Session duration in seconds
  int get sessionDurationSeconds {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  /// Recent study sessions
  List<StudySession> get recentSessions => List.unmodifiable(_recentSessions);

  /// Overall statistics
  Map<String, dynamic> get overallStats => Map.unmodifiable(_overallStats);

  // ============================================================
  // Session Management
  // ============================================================

  /// Start a new study session
  void startSession({
    required String goalId,
    String? deckId,
    StudySessionType sessionType = StudySessionType.flashcards,
  }) {
    _currentGoalId = goalId;
    _currentDeckId = deckId;
    _sessionType = sessionType;
    _sessionStartTime = DateTime.now();
    _cardsReviewed = 0;
    _correctAnswers = 0;
    notifyListeners();
  }

  /// Record a card review during the session
  void recordCardReview({required bool wasCorrect}) {
    if (!isSessionActive) return;
    _cardsReviewed++;
    if (wasCorrect) _correctAnswers++;
    notifyListeners();
  }

  /// End the current study session and save it
  Future<StudySession?> endSession() async {
    if (!isSessionActive || _currentGoalId == null) return null;

    final session = StudySession.create(
      goalId: _currentGoalId!,
      deckId: _currentDeckId,
      sessionType: _sessionType,
      startedAt: _sessionStartTime!,
      endedAt: DateTime.now(),
      cardsReviewed: _cardsReviewed,
      correctAnswers: _correctAnswers,
    );

    await _db.insertStudySession(session);

    // Reset session state
    _sessionStartTime = null;
    _currentGoalId = null;
    _currentDeckId = null;
    _cardsReviewed = 0;
    _correctAnswers = 0;

    // Refresh recent sessions
    await loadRecentSessions();

    notifyListeners();
    return session;
  }

  /// Cancel the current session without saving
  void cancelSession() {
    _sessionStartTime = null;
    _currentGoalId = null;
    _currentDeckId = null;
    _cardsReviewed = 0;
    _correctAnswers = 0;
    notifyListeners();
  }

  // ============================================================
  // Statistics
  // ============================================================

  /// Load recent study sessions
  Future<void> loadRecentSessions({int limit = 10}) async {
    _recentSessions = await _db.getRecentStudySessions(limit: limit);
    notifyListeners();
  }

  /// Load overall statistics
  Future<void> loadOverallStats() async {
    _overallStats = await _db.getOverallStats();

    // Add time-based stats
    _overallStats['today_study_time'] = await _db.getTodayStudyTime();
    _overallStats['this_week_study_time'] = await _db.getThisWeekStudyTime();

    notifyListeners();
  }

  /// Refresh overall statistics (call after study session ends)
  Future<void> refreshOverallStats() async {
    await loadOverallStats();
  }

  /// Get study sessions for a specific goal
  Future<List<StudySession>> getSessionsForGoal(String goalId) async {
    return await _db.getStudySessionsForGoal(goalId);
  }

  /// Get total study time for a goal
  Future<int> getTotalStudyTimeForGoal(String goalId) async {
    return await _db.getTotalStudyTimeForGoal(goalId);
  }

  /// Format seconds as a human-readable duration string
  static String formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '${minutes}m';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  /// Format seconds as a detailed duration string
  static String formatDetailedDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return '$minutes minutes';
      }
      return '$minutes min $remainingSeconds sec';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      if (minutes == 0) {
        return '$hours hours';
      }
      return '${hours}h ${minutes}m';
    }
  }
}
