import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService Tests', () {
    late PreferencesService prefsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefsService = PreferencesService();
      await prefsService.init();
    });

    test('Default theme mode is dark', () {
      expect(prefsService.getThemeMode(), 'dark');
    });

    test('Set and get theme mode', () async {
      await prefsService.setThemeMode('light');
      expect(prefsService.getThemeMode(), 'light');

      await prefsService.setThemeMode('system');
      expect(prefsService.getThemeMode(), 'system');
    });

    test('Default TTS is enabled', () {
      expect(prefsService.isTtsEnabled(), true);
    });

    test('Set and get TTS enabled', () async {
      await prefsService.setTtsEnabled(false);
      expect(prefsService.isTtsEnabled(), false);

      await prefsService.setTtsEnabled(true);
      expect(prefsService.isTtsEnabled(), true);
    });

    test('Default TTS auto-play is disabled', () {
      expect(prefsService.isTtsAutoPlayEnabled(), false);
    });

    test('Set and get TTS auto-play', () async {
      await prefsService.setTtsAutoPlay(true);
      expect(prefsService.isTtsAutoPlayEnabled(), true);

      await prefsService.setTtsAutoPlay(false);
      expect(prefsService.isTtsAutoPlayEnabled(), false);
    });

    test('Default quiz timer is disabled', () {
      expect(prefsService.isQuizTimerEnabled(), false);
    });

    test('Set and get quiz timer', () async {
      await prefsService.setQuizTimerEnabled(true);
      expect(prefsService.isQuizTimerEnabled(), true);
    });

    test('Default quiz shuffle is enabled', () {
      expect(prefsService.isQuizShuffleEnabled(), true);
    });

    test('Set and get quiz shuffle', () async {
      await prefsService.setQuizShuffle(false);
      expect(prefsService.isQuizShuffleEnabled(), false);
    });

    test('Default cards per session is 20', () {
      expect(prefsService.getCardsPerSession(), 20);
    });

    test('Set and get cards per session', () async {
      await prefsService.setCardsPerSession(50);
      expect(prefsService.getCardsPerSession(), 50);

      await prefsService.setCardsPerSession(10);
      expect(prefsService.getCardsPerSession(), 10);
    });

    test('Default LLM provider is none', () {
      expect(prefsService.getLlmProvider(), 'none');
    });

    test('Set and get LLM provider', () async {
      await prefsService.setLlmProvider('openai');
      expect(prefsService.getLlmProvider(), 'openai');

      await prefsService.setLlmProvider('ollama');
      expect(prefsService.getLlmProvider(), 'ollama');
    });

    test('Set and get LLM API key', () async {
      expect(prefsService.getLlmApiKey(), isNull);

      await prefsService.setLlmApiKey('test-api-key-123');
      expect(prefsService.getLlmApiKey(), 'test-api-key-123');
    });

    test('Set and get LLM base URL', () async {
      expect(prefsService.getLlmBaseUrl(), isNull);

      await prefsService.setLlmBaseUrl('http://localhost:11434');
      expect(prefsService.getLlmBaseUrl(), 'http://localhost:11434');
    });

    test('Set and get LLM model', () async {
      expect(prefsService.getLlmModel(), isNull);

      await prefsService.setLlmModel('gpt-4');
      expect(prefsService.getLlmModel(), 'gpt-4');
    });

    test('Check if LLM is configured', () async {
      expect(prefsService.isLlmConfigured(), false);

      await prefsService.setLlmProvider('openai');
      expect(prefsService.isLlmConfigured(), false);

      await prefsService.setLlmApiKey('test-key');
      expect(prefsService.isLlmConfigured(), true);
    });

    test('Clear LLM settings', () async {
      await prefsService.setLlmProvider('openai');
      await prefsService.setLlmApiKey('test-key');
      await prefsService.setLlmBaseUrl('http://test');
      await prefsService.setLlmModel('gpt-4');

      await prefsService.clearLlmSettings();

      expect(prefsService.getLlmProvider(), 'none');
      expect(prefsService.getLlmApiKey(), isNull);
      expect(prefsService.getLlmBaseUrl(), isNull);
      expect(prefsService.getLlmModel(), isNull);
      expect(prefsService.isLlmConfigured(), false);
    });

    test('Clear all preferences', () async {
      await prefsService.setThemeMode('light');
      await prefsService.setTtsEnabled(false);
      await prefsService.setCardsPerSession(50);

      await prefsService.clearAll();

      expect(prefsService.getThemeMode(), 'dark');
      expect(prefsService.isTtsEnabled(), true);
      expect(prefsService.getCardsPerSession(), 20);
    });
  });
}
