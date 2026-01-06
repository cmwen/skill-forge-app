import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/models/deck.dart';

void main() {
  group('Deck Model Tests', () {
    test('Create deck with factory', () {
      final deck = Deck.create(
        goalId: 'goal-1',
        name: 'Test Deck',
        description: 'A test deck',
        source: 'Manual',
      );

      expect(deck.id, isNotEmpty);
      expect(deck.goalId, 'goal-1');
      expect(deck.name, 'Test Deck');
      expect(deck.description, 'A test deck');
      expect(deck.source, 'Manual');
      expect(deck.totalStudyTimeSeconds, 0);
      expect(deck.lastStudiedAt, isNull);
    });

    test('Serialize to Map', () {
      final deck = Deck(
        id: 'deck-1',
        goalId: 'goal-1',
        name: 'Spanish Verbs',
        description: 'Common Spanish verbs',
        source: 'AI Generated',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        totalStudyTimeSeconds: 1200,
        lastStudiedAt: DateTime(2026, 1, 5),
      );

      final map = deck.toMap();

      expect(map['id'], 'deck-1');
      expect(map['goal_id'], 'goal-1');
      expect(map['name'], 'Spanish Verbs');
      expect(map['description'], 'Common Spanish verbs');
      expect(map['source'], 'AI Generated');
      expect(map['total_study_time_seconds'], 1200);
      expect(map['last_studied_at'], isNotNull);
    });

    test('Deserialize from Map', () {
      final map = {
        'id': 'deck-1',
        'goal_id': 'goal-1',
        'name': 'Test Deck',
        'description': 'Description',
        'source': 'Manual',
        'created_at': DateTime(2026, 1, 1).toIso8601String(),
        'updated_at': DateTime(2026, 1, 1).toIso8601String(),
        'total_study_time_seconds': 600,
        'last_studied_at': DateTime(2026, 1, 3).toIso8601String(),
      };

      final deck = Deck.fromMap(map);

      expect(deck.id, 'deck-1');
      expect(deck.goalId, 'goal-1');
      expect(deck.name, 'Test Deck');
      expect(deck.totalStudyTimeSeconds, 600);
      expect(deck.lastStudiedAt, isNotNull);
    });

    test('copyWith creates modified copy', () {
      final original = Deck.create(
        goalId: 'goal-1',
        name: 'Original',
        source: 'Manual',
      );

      final modified = original.copyWith(
        name: 'Modified',
        description: 'New description',
        totalStudyTimeSeconds: 3600,
      );

      expect(modified.id, original.id);
      expect(modified.goalId, original.goalId);
      expect(modified.name, 'Modified');
      expect(modified.description, 'New description');
      expect(modified.totalStudyTimeSeconds, 3600);
    });

    test('Update last studied time', () {
      final deck = Deck.create(
        goalId: 'goal-1',
        name: 'Test',
        source: 'Manual',
      );

      expect(deck.lastStudiedAt, isNull);

      final now = DateTime.now();
      final updated = deck.copyWith(lastStudiedAt: now);

      expect(updated.lastStudiedAt, isNotNull);
      expect(updated.lastStudiedAt, now);
    });

    test('Accumulate study time', () {
      var deck = Deck.create(
        goalId: 'goal-1',
        name: 'Test',
        source: 'Manual',
      );

      expect(deck.totalStudyTimeSeconds, 0);

      // Add 10 minutes of study time
      deck = deck.copyWith(totalStudyTimeSeconds: 600);
      expect(deck.totalStudyTimeSeconds, 600);

      // Add another 5 minutes
      deck = deck.copyWith(totalStudyTimeSeconds: deck.totalStudyTimeSeconds + 300);
      expect(deck.totalStudyTimeSeconds, 900);
    });

    test('Handle null description', () {
      final deck = Deck.create(
        goalId: 'goal-1',
        name: 'Test',
        source: 'Manual',
      );

      expect(deck.description, isNull);

      final map = deck.toMap();
      expect(map['description'], isNull);

      final deserialized = Deck.fromMap(map);
      expect(deserialized.description, isNull);
    });
  });
}
