import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting app preferences and settings.
class PreferencesService {
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyTtsEnabled = 'tts_enabled';
  static const String _keyTtsAutoPlay = 'tts_auto_play';
  static const String _keyQuizTimerEnabled = 'quiz_timer_enabled';
  static const String _keyQuizShuffle = 'quiz_shuffle';
  static const String _keyCardsPerSession = 'cards_per_session';
  static const String _keyLlmProvider = 'llm_provider';
  static const String _keyLlmApiKey = 'llm_api_key';
  static const String _keyLlmBaseUrl = 'llm_base_url';
  static const String _keyLlmModel = 'llm_model';

  SharedPreferences? _prefs;

  /// Initialize the preferences service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ============================================================
  // Appearance Settings
  // ============================================================

  /// Get theme mode ('dark', 'light', or 'system')
  String getThemeMode() {
    return _preferences.getString(_keyThemeMode) ?? 'dark';
  }

  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    await _preferences.setString(_keyThemeMode, mode);
  }

  // ============================================================
  // Audio Settings
  // ============================================================

  /// Check if TTS is enabled
  bool isTtsEnabled() {
    return _preferences.getBool(_keyTtsEnabled) ?? true;
  }

  /// Enable/disable TTS
  Future<void> setTtsEnabled(bool enabled) async {
    await _preferences.setBool(_keyTtsEnabled, enabled);
  }

  /// Check if TTS auto-play is enabled
  bool isTtsAutoPlayEnabled() {
    return _preferences.getBool(_keyTtsAutoPlay) ?? false;
  }

  /// Enable/disable TTS auto-play
  Future<void> setTtsAutoPlay(bool enabled) async {
    await _preferences.setBool(_keyTtsAutoPlay, enabled);
  }

  // ============================================================
  // Quiz Settings
  // ============================================================

  /// Check if quiz timer is enabled
  bool isQuizTimerEnabled() {
    return _preferences.getBool(_keyQuizTimerEnabled) ?? false;
  }

  /// Enable/disable quiz timer
  Future<void> setQuizTimerEnabled(bool enabled) async {
    await _preferences.setBool(_keyQuizTimerEnabled, enabled);
  }

  /// Check if quiz shuffle is enabled
  bool isQuizShuffleEnabled() {
    return _preferences.getBool(_keyQuizShuffle) ?? true;
  }

  /// Enable/disable quiz shuffle
  Future<void> setQuizShuffle(bool enabled) async {
    await _preferences.setBool(_keyQuizShuffle, enabled);
  }

  // ============================================================
  // Practice Settings
  // ============================================================

  /// Get cards per session
  int getCardsPerSession() {
    return _preferences.getInt(_keyCardsPerSession) ?? 20;
  }

  /// Set cards per session
  Future<void> setCardsPerSession(int count) async {
    await _preferences.setInt(_keyCardsPerSession, count);
  }

  // ============================================================
  // LLM Provider Settings
  // ============================================================

  /// Get configured LLM provider ('none', 'openai', 'openrouter', 'ollama')
  String getLlmProvider() {
    return _preferences.getString(_keyLlmProvider) ?? 'none';
  }

  /// Set LLM provider
  Future<void> setLlmProvider(String provider) async {
    await _preferences.setString(_keyLlmProvider, provider);
  }

  /// Get LLM API key
  String? getLlmApiKey() {
    return _preferences.getString(_keyLlmApiKey);
  }

  /// Set LLM API key
  Future<void> setLlmApiKey(String apiKey) async {
    await _preferences.setString(_keyLlmApiKey, apiKey);
  }

  /// Get LLM base URL (for custom endpoints)
  String? getLlmBaseUrl() {
    return _preferences.getString(_keyLlmBaseUrl);
  }

  /// Set LLM base URL
  Future<void> setLlmBaseUrl(String url) async {
    await _preferences.setString(_keyLlmBaseUrl, url);
  }

  /// Get LLM model name
  String? getLlmModel() {
    return _preferences.getString(_keyLlmModel);
  }

  /// Set LLM model name
  Future<void> setLlmModel(String model) async {
    await _preferences.setString(_keyLlmModel, model);
  }

  /// Clear all LLM settings
  Future<void> clearLlmSettings() async {
    await Future.wait([
      _preferences.remove(_keyLlmProvider),
      _preferences.remove(_keyLlmApiKey),
      _preferences.remove(_keyLlmBaseUrl),
      _preferences.remove(_keyLlmModel),
    ]);
  }

  /// Check if LLM is configured
  bool isLlmConfigured() {
    final provider = getLlmProvider();
    return provider != 'none' && getLlmApiKey() != null;
  }

  // ============================================================
  // Utilities
  // ============================================================

  /// Clear all preferences
  Future<void> clearAll() async {
    await _preferences.clear();
  }
}
