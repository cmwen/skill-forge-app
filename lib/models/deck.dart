import 'package:uuid/uuid.dart';

/// Represents a deck of flashcards within a learning goal.
///
/// Decks organize related cards under a specific topic or theme.
/// Each deck belongs to exactly one learning goal.
///
/// Hierarchy: Goal → Deck → Card
class Deck {
  /// Unique identifier for the deck
  final String id;

  /// ID of the learning goal this deck belongs to
  final String goalId;

  /// Display name (e.g., "Episode 1-5 Dialogue")
  final String name;

  /// Optional description
  final String? description;

  /// When the deck was created
  final DateTime createdAt;

  /// When the deck was last updated
  final DateTime updatedAt;

  /// When the user last studied this deck
  final DateTime? lastStudiedAt;

  /// Total time spent studying this deck in seconds
  final int totalStudyTimeSeconds;

  /// Source of the content (e.g., "ChatGPT", "Manual")
  final String? source;

  const Deck({
    required this.id,
    required this.goalId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.lastStudiedAt,
    this.totalStudyTimeSeconds = 0,
    this.source,
  });

  /// Creates a new deck with a generated ID
  factory Deck.create({
    required String goalId,
    required String name,
    String? description,
    String? source,
  }) {
    final now = DateTime.now();
    return Deck(
      id: const Uuid().v4(),
      goalId: goalId,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
      source: source,
    );
  }

  /// Creates a copy with updated fields
  Deck copyWith({
    String? goalId,
    String? name,
    String? description,
    DateTime? updatedAt,
    DateTime? lastStudiedAt,
    int? totalStudyTimeSeconds,
    String? source,
  }) {
    return Deck(
      id: id,
      goalId: goalId ?? this.goalId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      totalStudyTimeSeconds:
          totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
      source: source ?? this.source,
    );
  }

  /// Converts to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_studied_at': lastStudiedAt?.toIso8601String(),
      'total_study_time_seconds': totalStudyTimeSeconds,
      'source': source,
    };
  }

  /// Creates from a database map
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'] as String,
      goalId: map['goal_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastStudiedAt: map['last_studied_at'] != null
          ? DateTime.parse(map['last_studied_at'] as String)
          : null,
      totalStudyTimeSeconds: map['total_study_time_seconds'] as int? ?? 0,
      source: map['source'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Deck(id: $id, name: $name, goalId: $goalId)';
}
