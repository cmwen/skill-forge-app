import 'package:uuid/uuid.dart';

/// Represents a learning goal that organizes decks and cards.
///
/// A learning goal is the top-level organizational unit in Skill Forge.
/// Users create goals for specific learning objectives (e.g., "Learn Spanish for Travel")
/// and all content is organized under goals.
///
/// Hierarchy: Goal → Deck → Card
class LearningGoal {
  /// Unique identifier for the goal
  final String id;

  /// Display name (e.g., "Japanese - One Piece")
  final String name;

  /// Optional description for context
  final String? description;

  /// Emoji or icon identifier (e.g., "🇯🇵")
  final String icon;

  /// Target completion date (optional)
  final DateTime? targetDate;

  /// When the goal was created
  final DateTime createdAt;

  /// When the goal was last updated
  final DateTime updatedAt;

  /// When the user last studied content in this goal
  final DateTime? lastStudiedAt;

  /// Whether the goal is archived (completed or paused)
  final bool isArchived;

  /// Total time spent studying this goal in seconds
  final int totalStudyTimeSeconds;

  const LearningGoal({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.lastStudiedAt,
    this.isArchived = false,
    this.totalStudyTimeSeconds = 0,
  });

  /// Creates a new learning goal with a generated ID
  factory LearningGoal.create({
    required String name,
    String? description,
    String icon = '📚',
    DateTime? targetDate,
  }) {
    final now = DateTime.now();
    return LearningGoal(
      id: const Uuid().v4(),
      name: name,
      description: description,
      icon: icon,
      targetDate: targetDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a copy with updated fields
  LearningGoal copyWith({
    String? name,
    String? description,
    String? icon,
    DateTime? targetDate,
    DateTime? updatedAt,
    DateTime? lastStudiedAt,
    bool? isArchived,
    int? totalStudyTimeSeconds,
  }) {
    return LearningGoal(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      isArchived: isArchived ?? this.isArchived,
      totalStudyTimeSeconds:
          totalStudyTimeSeconds ?? this.totalStudyTimeSeconds,
    );
  }

  /// Converts to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_studied_at': lastStudiedAt?.toIso8601String(),
      'is_archived': isArchived ? 1 : 0,
      'total_study_time_seconds': totalStudyTimeSeconds,
    };
  }

  /// Creates from a database map
  factory LearningGoal.fromMap(Map<String, dynamic> map) {
    return LearningGoal(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String,
      targetDate: map['target_date'] != null
          ? DateTime.parse(map['target_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastStudiedAt: map['last_studied_at'] != null
          ? DateTime.parse(map['last_studied_at'] as String)
          : null,
      isArchived: (map['is_archived'] as int) == 1,
      totalStudyTimeSeconds: map['total_study_time_seconds'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningGoal &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LearningGoal(id: $id, name: $name, icon: $icon)';
}
