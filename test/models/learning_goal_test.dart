import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/models/learning_goal.dart';

void main() {
  group('LearningGoal Model Tests', () {
    test('Create learning goal with all fields', () {
      final goal = LearningGoal(
        id: 'test-id',
        name: 'Learn Flutter',
        description: 'Master Flutter development',
        icon: '📱',
        targetDate: DateTime(2026, 12, 31),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isArchived: false,
        totalStudyTimeSeconds: 3600,
      );

      expect(goal.id, 'test-id');
      expect(goal.name, 'Learn Flutter');
      expect(goal.description, 'Master Flutter development');
      expect(goal.icon, '📱');
      expect(goal.isArchived, false);
      expect(goal.totalStudyTimeSeconds, 3600);
    });

    test('Create learning goal with factory constructor', () {
      final goal = LearningGoal.create(
        name: 'Learn Dart',
        icon: '🎯',
      );

      expect(goal.id, isNotEmpty);
      expect(goal.name, 'Learn Dart');
      expect(goal.icon, '🎯');
      expect(goal.isArchived, false);
      expect(goal.totalStudyTimeSeconds, 0);
      expect(goal.createdAt, isNotNull);
      expect(goal.updatedAt, isNotNull);
    });

    test('Serialize to Map', () {
      final goal = LearningGoal(
        id: 'test-id',
        name: 'Learn Flutter',
        description: 'Test description',
        icon: '📱',
        targetDate: DateTime(2026, 12, 31),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        isArchived: false,
        totalStudyTimeSeconds: 1800,
      );

      final map = goal.toMap();

      expect(map['id'], 'test-id');
      expect(map['name'], 'Learn Flutter');
      expect(map['description'], 'Test description');
      expect(map['icon'], '📱');
      expect(map['is_archived'], 0);
      expect(map['total_study_time_seconds'], 1800);
    });

    test('Deserialize from Map', () {
      final map = {
        'id': 'test-id',
        'name': 'Learn Flutter',
        'description': 'Test description',
        'icon': '📱',
        'target_date': DateTime(2026, 12, 31).toIso8601String(),
        'created_at': DateTime(2026, 1, 1).toIso8601String(),
        'updated_at': DateTime(2026, 1, 1).toIso8601String(),
        'is_archived': 0,
        'total_study_time_seconds': 1800,
      };

      final goal = LearningGoal.fromMap(map);

      expect(goal.id, 'test-id');
      expect(goal.name, 'Learn Flutter');
      expect(goal.description, 'Test description');
      expect(goal.icon, '📱');
      expect(goal.isArchived, false);
      expect(goal.totalStudyTimeSeconds, 1800);
    });

    test('copyWith creates modified copy', () {
      final original = LearningGoal.create(
        name: 'Original',
        icon: '🎯',
      );

      final modified = original.copyWith(
        name: 'Modified',
        isArchived: true,
        totalStudyTimeSeconds: 7200,
      );

      expect(modified.id, original.id);
      expect(modified.name, 'Modified');
      expect(modified.icon, '🎯');
      expect(modified.isArchived, true);
      expect(modified.totalStudyTimeSeconds, 7200);
    });

    test('Archive goal changes isArchived flag', () {
      final goal = LearningGoal.create(name: 'Test', icon: '📚');
      expect(goal.isArchived, false);

      final archived = goal.copyWith(isArchived: true);
      expect(archived.isArchived, true);
    });
  });
}
