import 'package:uuid/uuid.dart';

/// Type of study session
enum StudySessionType {
  flashcards,
  quiz,
}

/// Represents a completed study session.
///
/// Tracks time spent, cards reviewed, and performance metrics
/// for a single study session.
class StudySession {
  /// Unique identifier for the session
  final String id;

  /// ID of the goal this session belongs to
  final String goalId;

  /// ID of the deck studied (null if studying multiple decks)
  final String? deckId;

  /// Type of study session
  final StudySessionType sessionType;

  /// When the session started
  final DateTime startedAt;

  /// When the session ended
  final DateTime endedAt;

  /// Duration in seconds
  final int durationSeconds;

  /// Number of cards reviewed
  final int cardsReviewed;

  /// Number of correct answers
  final int correctAnswers;

  /// Average time per card in seconds
  final double avgTimePerCard;

  const StudySession({
    required this.id,
    required this.goalId,
    this.deckId,
    required this.sessionType,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.cardsReviewed,
    required this.correctAnswers,
    required this.avgTimePerCard,
  });

  /// Creates a new study session with a generated ID
  factory StudySession.create({
    required String goalId,
    String? deckId,
    required StudySessionType sessionType,
    required DateTime startedAt,
    required DateTime endedAt,
    required int cardsReviewed,
    required int correctAnswers,
  }) {
    final durationSeconds = endedAt.difference(startedAt).inSeconds;
    final avgTimePerCard = cardsReviewed > 0 
        ? durationSeconds / cardsReviewed 
        : 0.0;
    
    return StudySession(
      id: const Uuid().v4(),
      goalId: goalId,
      deckId: deckId,
      sessionType: sessionType,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      cardsReviewed: cardsReviewed,
      correctAnswers: correctAnswers,
      avgTimePerCard: avgTimePerCard,
    );
  }

  /// Accuracy percentage (0-100)
  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return (correctAnswers / cardsReviewed) * 100;
  }

  /// Converts to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'deck_id': deckId,
      'session_type': sessionType.name,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt.toIso8601String(),
      'duration_seconds': durationSeconds,
      'cards_reviewed': cardsReviewed,
      'correct_answers': correctAnswers,
      'avg_time_per_card': avgTimePerCard,
    };
  }

  /// Creates from a database map
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      deckId: map['deck_id'] as String?,
      sessionType: StudySessionType.values.firstWhere(
        (e) => e.name == map['session_type'],
        orElse: () => StudySessionType.flashcards,
      ),
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: DateTime.parse(map['ended_at'] as String),
      durationSeconds: map['duration_seconds'] as int,
      cardsReviewed: map['cards_reviewed'] as int,
      correctAnswers: map['correct_answers'] as int,
      avgTimePerCard: (map['avg_time_per_card'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySession && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StudySession(id: $id, cards: $cardsReviewed, accuracy: ${accuracy.toStringAsFixed(1)}%)';
}
