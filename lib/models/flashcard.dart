import 'package:uuid/uuid.dart';

/// Represents a single flashcard within a deck.
///
/// Flashcards have front and back content, and track
/// mastery level through spaced repetition metrics.
///
/// Hierarchy: Goal → Deck → Card
class Flashcard {
  /// Unique identifier for the card
  final String id;

  /// ID of the deck this card belongs to
  final String deckId;

  /// Front content (question, term, prompt)
  final String front;

  /// Back content (answer, definition, response)
  final String back;

  /// Optional additional notes or context
  final String? notes;

  /// When the card was created
  final DateTime createdAt;

  /// When the card was last updated
  final DateTime updatedAt;

  /// When the card was last reviewed
  final DateTime? lastReviewedAt;

  /// Spaced repetition: next scheduled review date
  final DateTime? nextReviewAt;

  /// Number of times this card has been reviewed
  final int reviewCount;

  /// Number of times answered correctly
  final int correctCount;

  /// Current mastery level (0-100)
  /// 0 = new, 100 = fully mastered
  final int masteryLevel;

  /// Spaced repetition interval in days
  final double intervalDays;

  /// Ease factor for spaced repetition (default 2.5)
  final double easeFactor;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.masteryLevel = 0,
    this.intervalDays = 1.0,
    this.easeFactor = 2.5,
  });

  /// Creates a new flashcard with a generated ID
  factory Flashcard.create({
    required String deckId,
    required String front,
    required String back,
    String? notes,
  }) {
    final now = DateTime.now();
    return Flashcard(
      id: const Uuid().v4(),
      deckId: deckId,
      front: front,
      back: back,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      nextReviewAt: now, // Due immediately for new cards
    );
  }

  /// Whether this card is considered mastered (>= 80% mastery)
  bool get isMastered => masteryLevel >= 80;

  /// Whether this card is due for review
  bool get isDue {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  /// Creates a copy with updated fields after a review
  ///
  /// [quality] is the user's rating: 0 = Hard, 1 = Medium, 2 = Easy
  Flashcard recordReview({required int quality}) {
    final now = DateTime.now();
    final wasCorrect = quality >= 1;
    
    // Simple SM-2 implementation
    double newEaseFactor = easeFactor;
    double newInterval = intervalDays;
    int newMastery = masteryLevel;
    
    if (quality == 0) {
      // Hard: reduce interval, decrease mastery
      newInterval = 1.0;
      newMastery = (masteryLevel - 20).clamp(0, 100);
      newEaseFactor = (easeFactor - 0.2).clamp(1.3, 2.5);
    } else if (quality == 1) {
      // Medium: small increase
      newInterval = intervalDays * 1.2;
      newMastery = (masteryLevel + 10).clamp(0, 100);
    } else {
      // Easy: larger increase
      newInterval = intervalDays * easeFactor;
      newMastery = (masteryLevel + 20).clamp(0, 100);
      newEaseFactor = (easeFactor + 0.1).clamp(1.3, 2.5);
    }
    
    return copyWith(
      lastReviewedAt: now,
      nextReviewAt: now.add(Duration(hours: (newInterval * 24).round())),
      reviewCount: reviewCount + 1,
      correctCount: wasCorrect ? correctCount + 1 : correctCount,
      masteryLevel: newMastery,
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      updatedAt: now,
    );
  }

  /// Creates a copy with updated fields
  Flashcard copyWith({
    String? deckId,
    String? front,
    String? back,
    String? notes,
    DateTime? updatedAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? reviewCount,
    int? correctCount,
    int? masteryLevel,
    double? intervalDays,
    double? easeFactor,
  }) {
    return Flashcard(
      id: id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  /// Converts to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'front': front,
      'back': back,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
      'review_count': reviewCount,
      'correct_count': correctCount,
      'mastery_level': masteryLevel,
      'interval_days': intervalDays,
      'ease_factor': easeFactor,
    };
  }

  /// Creates from a database map
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      deckId: map['deck_id'] as String,
      front: map['front'] as String,
      back: map['back'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastReviewedAt: map['last_reviewed_at'] != null
          ? DateTime.parse(map['last_reviewed_at'] as String)
          : null,
      nextReviewAt: map['next_review_at'] != null
          ? DateTime.parse(map['next_review_at'] as String)
          : null,
      reviewCount: map['review_count'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      masteryLevel: map['mastery_level'] as int? ?? 0,
      intervalDays: (map['interval_days'] as num?)?.toDouble() ?? 1.0,
      easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Flashcard && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Flashcard(id: $id, front: $front)';
}
