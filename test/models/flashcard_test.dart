import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/models/flashcard.dart';
import 'package:skill_forge/models/study_session.dart';

void main() {
  group('Flashcard Model Tests', () {
    test('Create flashcard with factory', () {
      final card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Question?',
        back: 'Answer!',
      );

      expect(card.id, isNotEmpty);
      expect(card.deckId, 'deck-1');
      expect(card.front, 'Question?');
      expect(card.back, 'Answer!');
      expect(card.masteryLevel, 0);
      expect(card.intervalDays, 1.0); // Default is 1.0 for new cards
      expect(card.easeFactor, 2.5);
      expect(card.reviewCount, 0);
      expect(card.correctCount, 0);
    });

    test('Serialize and deserialize flashcard', () {
      final card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Test Front',
        back: 'Test Back',
        notes: 'Test Notes',
      );

      final map = card.toMap();
      final deserialized = Flashcard.fromMap(map);

      expect(deserialized.id, card.id);
      expect(deserialized.deckId, card.deckId);
      expect(deserialized.front, card.front);
      expect(deserialized.back, card.back);
      expect(deserialized.notes, card.notes);
      expect(deserialized.masteryLevel, card.masteryLevel);
    });

    test('Record easy review increases mastery', () {
      final card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
      );

      final updated = card.recordReview(quality: 2); // Easy

      expect(updated.reviewCount, 1);
      expect(updated.correctCount, 1);
      expect(updated.masteryLevel, greaterThan(card.masteryLevel));
      expect(updated.intervalDays, greaterThan(0));
      expect(updated.nextReviewAt, isNotNull);
    });

    test('Record hard review decreases ease factor', () {
      final card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
      ).copyWith(easeFactor: 2.5);

      final updated = card.recordReview(quality: 0); // Hard

      expect(updated.easeFactor, lessThan(2.5));
      expect(updated.easeFactor, greaterThanOrEqualTo(1.3));
    });

    test('Multiple reviews increase interval exponentially', () {
      var card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
      );

      card = card.recordReview(quality: 1); // Medium
      final firstInterval = card.intervalDays;

      card = card.recordReview(quality: 1); // Medium
      final secondInterval = card.intervalDays;

      card = card.recordReview(quality: 1); // Medium
      final thirdInterval = card.intervalDays;

      expect(secondInterval, greaterThan(firstInterval));
      expect(thirdInterval, greaterThan(secondInterval));
    });

    test('Mastery level reaches 100 with perfect reviews', () {
      var card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
      );

      // Do 20 perfect reviews
      for (int i = 0; i < 20; i++) {
        card = card.recordReview(quality: 2); // Easy
      }

      expect(card.masteryLevel, 100);
    });

    test('Card is due when nextReviewAt is in past', () {
      final card = Flashcard.create(
        deckId: 'deck-1',
        front: 'Q',
        back: 'A',
      ).copyWith(
        nextReviewAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final now = DateTime.now();
      expect(card.nextReviewAt!.isBefore(now), true);
    });
  });

  group('StudySession Model Tests', () {
    test('Create study session', () {
      final session = StudySession.create(
        goalId: 'goal-1',
        deckId: 'deck-1',
        sessionType: StudySessionType.flashcards,
        startedAt: DateTime.now(),
        endedAt: DateTime.now().add(const Duration(minutes: 10)),
        cardsReviewed: 20,
        correctAnswers: 15,
      );

      expect(session.id, isNotEmpty);
      expect(session.goalId, 'goal-1');
      expect(session.deckId, 'deck-1');
      expect(session.sessionType, StudySessionType.flashcards);
      expect(session.cardsReviewed, 20);
      expect(session.correctAnswers, 15);
      expect(session.accuracy, 75.0);
    });

    test('Calculate accuracy correctly', () {
      final session = StudySession.create(
        goalId: 'goal-1',
        sessionType: StudySessionType.quiz,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        cardsReviewed: 50,
        correctAnswers: 42,
      );

      expect(session.accuracy, 84.0);
    });

    test('Zero cards reviewed gives zero accuracy', () {
      final session = StudySession.create(
        goalId: 'goal-1',
        sessionType: StudySessionType.flashcards,
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        cardsReviewed: 0,
        correctAnswers: 0,
      );

      expect(session.accuracy, 0.0);
    });

    test('Session duration calculation', () {
      final startTime = DateTime(2026, 1, 6, 10, 0, 0);
      final endTime = DateTime(2026, 1, 6, 10, 15, 30);

      final session = StudySession.create(
        goalId: 'goal-1',
        sessionType: StudySessionType.flashcards,
        startedAt: startTime,
        endedAt: endTime,
        cardsReviewed: 10,
        correctAnswers: 8,
      );

      final duration = session.endedAt.difference(session.startedAt);
      expect(duration.inMinutes, 15);
      expect(duration.inSeconds, 930);
    });

    test('Serialize and deserialize session', () {
      final session = StudySession.create(
        goalId: 'goal-1',
        deckId: 'deck-1',
        sessionType: StudySessionType.quiz,
        startedAt: DateTime(2026, 1, 6, 10, 0, 0),
        endedAt: DateTime(2026, 1, 6, 10, 20, 0),
        cardsReviewed: 30,
        correctAnswers: 25,
      );

      final map = session.toMap();
      final deserialized = StudySession.fromMap(map);

      expect(deserialized.id, session.id);
      expect(deserialized.goalId, session.goalId);
      expect(deserialized.deckId, session.deckId);
      expect(deserialized.sessionType, session.sessionType);
      expect(deserialized.cardsReviewed, session.cardsReviewed);
      expect(deserialized.correctAnswers, session.correctAnswers);
      expect(deserialized.accuracy, session.accuracy);
    });
  });
}
