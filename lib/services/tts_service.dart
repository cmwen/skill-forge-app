import 'package:flutter_tts/flutter_tts.dart';
import 'preferences_service.dart';

/// Service for text-to-speech functionality.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final PreferencesService _prefs;

  bool _isInitialized = false;
  bool _isSpeaking = false;

  TtsService(this._prefs);

  /// Initialize TTS
  Future<void> init() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// Check if TTS is currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Speak text if TTS is enabled
  Future<void> speak(String text) async {
    if (!_prefs.isTtsEnabled()) return;
    if (!_isInitialized) await init();

    if (_isSpeaking) {
      await stop();
    }

    await _tts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    if (!_isInitialized) return;
    await _tts.stop();
    _isSpeaking = false;
  }

  /// Pause speaking
  Future<void> pause() async {
    if (!_isInitialized) return;
    await _tts.pause();
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (!_isInitialized) await init();
    await _tts.setLanguage(languageCode);
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) await init();
    await _tts.setSpeechRate(rate);
  }

  /// Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) await init();
    final languages = await _tts.getLanguages;
    return List<String>.from(languages);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
  }
}
