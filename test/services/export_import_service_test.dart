import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/services/export_import_service.dart';
import 'package:skill_forge/database/database_helper.dart';
import 'package:skill_forge/models/models.dart';
import 'dart:convert';

void main() {
  group('ExportImportService Tests', () {
    late DatabaseHelper dbHelper;
    late ExportImportService exportService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      dbHelper = DatabaseHelper();
      await dbHelper.database;
      exportService = ExportImportService(dbHelper);
    });

    tearDown(() async {
      await dbHelper.close();
    });

    test('Export empty database as JSON', () async {
      final json = await exportService.exportAsJson();
      final data = jsonDecode(json);

      expect(data['version'], '1.0');
      expect(data['exported_at'], isNotNull);
      expect(data['goals'], isEmpty);
      expect(data['decks'], isEmpty);
      expect(data['flashcards'], isEmpty);
      expect(data['study_sessions'], isEmpty);
    });

    test('Export database with data as JSON', () async {
      // Create test data
      final goal = await dbHelper.insertGoal(
        LearningGoal.create(name: 'Test Goal', icon: '📚'),
      );

      final deck = await dbHelper.insertDeck(
        Deck.create(
          goalId: goal.id,
          name: 'Test Deck',
          source: 'Manual',
        ),
      );

      await dbHelper.insertFlashcard(
        Flashcard.create(
          deckId: deck.id,
          front: 'Question',
          back: 'Answer',
        ),
      );

      final json = await exportService.exportAsJson();
      final data = jsonDecode(json);

      expect(data['goals'], hasLength(1));
      expect(data['decks'], hasLength(1));
      expect(data['flashcards'], hasLength(1));
      expect(data['goals'][0]['name'], 'Test Goal');
      expect(data['decks'][0]['name'], 'Test Deck');
      expect(data['flashcards'][0]['front'], 'Question');
    });

    test('Export as CSV includes all cards', () async {
      final goal = await dbHelper.insertGoal(
        LearningGoal.create(name: 'Spanish', icon: '🇪🇸'),
      );

      final deck = await dbHelper.insertDeck(
        Deck.create(
          goalId: goal.id,
          name: 'Verbs',
          source: 'Manual',
        ),
      );

      await dbHelper.insertFlashcard(
        Flashcard.create(
          deckId: deck.id,
          front: 'Hola',
          back: 'Hello',
        ),
      );

      await dbHelper.insertFlashcard(
        Flashcard.create(
          deckId: deck.id,
          front: 'Adiós',
          back: 'Goodbye',
        ),
      );

      final csv = await exportService.exportAsCsv();
      final lines = csv.split('\n');

      expect(lines.length, 3); // Header + 2 cards
      expect(lines[0], 'Front,Back,Deck,Goal');
      expect(lines[1], contains('Hola'));
      expect(lines[1], contains('Hello'));
      expect(lines[2], contains('Adiós'));
      expect(lines[2], contains('Goodbye'));
    });

    test('CSV escapes commas in content', () async {
      final goal = await dbHelper.insertGoal(
        LearningGoal.create(name: 'Test', icon: '📚'),
      );

      final deck = await dbHelper.insertDeck(
        Deck.create(
          goalId: goal.id,
          name: 'Deck, with, commas',
          source: 'Manual',
        ),
      );

      await dbHelper.insertFlashcard(
        Flashcard.create(
          deckId: deck.id,
          front: 'Question, with, commas',
          back: 'Answer, also, with, commas',
        ),
      );

      final csv = await exportService.exportAsCsv();

      expect(csv, contains('"Question, with, commas"'));
      expect(csv, contains('"Answer, also, with, commas"'));
      expect(csv, contains('"Deck, with, commas"'));
    });

    test('Import valid JSON data', () async {
      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'goals': [
          LearningGoal.create(name: 'Imported Goal', icon: '📥').toMap(),
        ],
        'decks': [],
        'flashcards': [],
        'study_sessions': [],
      };

      final json = jsonEncode(exportData);
      final result = await exportService.importFromJson(json);

      expect(result.success, true);
      expect(result.goalsImported, 1);
      expect(result.message, contains('1 goals'));

      final goals = await dbHelper.getAllGoals();
      expect(goals, hasLength(1));
      expect(goals[0].name, 'Imported Goal');
    });

    test('Import complete data set', () async {
      final goal = LearningGoal.create(name: 'Test Goal', icon: '📚');
      final deck = Deck.create(
        goalId: goal.id,
        name: 'Test Deck',
        source: 'Import',
      );
      final card = Flashcard.create(
        deckId: deck.id,
        front: 'Q',
        back: 'A',
      );
      final session = StudySession.create(
        goalId: goal.id,
        deckId: deck.id,
        sessionType: StudySessionType.flashcards,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        endedAt: DateTime.now(),
        cardsReviewed: 10,
        correctAnswers: 8,
      );

      final exportData = {
        'version': '1.0',
        'exported_at': DateTime.now().toIso8601String(),
        'goals': [goal.toMap()],
        'decks': [deck.toMap()],
        'flashcards': [card.toMap()],
        'study_sessions': [session.toMap()],
      };

      final json = jsonEncode(exportData);
      final result = await exportService.importFromJson(json);

      expect(result.success, true);
      expect(result.goalsImported, 1);
      expect(result.decksImported, 1);
      expect(result.cardsImported, 1);
      expect(result.sessionsImported, 1);
    });

    test('Import rejects invalid version', () async {
      final exportData = {
        'version': '2.0',
        'exported_at': DateTime.now().toIso8601String(),
        'goals': [],
      };

      final json = jsonEncode(exportData);
      final result = await exportService.importFromJson(json);

      expect(result.success, false);
      expect(result.message, contains('Unsupported export version'));
    });

    test('Import handles malformed JSON', () async {
      const invalidJson = '{ invalid json';
      final result = await exportService.importFromJson(invalidJson);

      expect(result.success, false);
      expect(result.message, contains('Import failed'));
    });
  });
}
