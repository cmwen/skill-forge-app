import 'dart:async';
import '../ollama_toolkit/ollama_toolkit.dart';

/// Service for generating flashcards using Ollama
class OllamaGenerationService {
  OllamaClient? _client;
  final OllamaConfigService _configService;

  OllamaGenerationService({
    OllamaClient? client,
    OllamaConfigService? configService,
  }) : _client = client,
       _configService = configService ?? OllamaConfigService();

  /// Initialize the service with saved configuration
  Future<void> init() async {
    // Get configured settings
    final baseUrl = await _configService.getBaseUrl();
    final timeoutSeconds = await _configService.getTimeout();

    // Initialize client with configured values
    _client = OllamaClient(
      baseUrl: baseUrl,
      timeout: Duration(seconds: timeoutSeconds),
    );
  }

  /// Check if Ollama server is available
  Future<bool> isAvailable() async {
    try {
      if (_client == null) {
        await init();
      }
      final response = await _client!.listModels();
      return response.models.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available models
  Future<List<OllamaModelInfo>> getAvailableModels() async {
    try {
      if (_client == null) {
        await init();
      }
      final response = await _client!.listModels();
      return response.models;
    } catch (e) {
      return [];
    }
  }

  /// Generate flashcards using Ollama
  Future<List<Map<String, String>>> generateFlashcards({
    required String topic,
    required int count,
    required String difficulty,
    required String contentType,
    String? goalContext,
    String? additionalContext,
    String? model,
    required Function(String) onProgress,
  }) async {
    if (_client == null) {
      await init();
    }

    // Get model from config or use provided one
    final selectedModel =
        model ??
        await _configService.getLastUsedModel() ??
        await _configService.getDefaultModel() ??
        'llama3.2';

    // Build the prompt
    final prompt = _buildPrompt(
      topic: topic,
      count: count,
      difficulty: difficulty,
      contentType: contentType,
      goalContext: goalContext,
      additionalContext: additionalContext,
    );

    // Prepare messages
    final messages = [
      OllamaMessage.system(
        '''You are an expert educational content creator. 
Generate flashcards in a clear, structured format.
Always respond with the exact format requested.
Do not include any explanations or additional text outside the flashcard format.''',
      ),
      OllamaMessage.user(prompt),
    ];

    // Generate content with streaming
    final cards = <Map<String, String>>[];
    final buffer = StringBuffer();

    try {
      await for (final chunk in _client!.chatStream(selectedModel, messages)) {
        final content = chunk.message.content;
        buffer.write(content);
        onProgress(content);
      }

      // Parse the generated content
      cards.addAll(_parseFlashcards(buffer.toString()));

      // Save the model as last used
      await _configService.setLastUsedModel(selectedModel);

      return cards;
    } catch (e) {
      throw OllamaGenerationException(
        'Failed to generate flashcards: $e',
        originalError: e,
      );
    }
  }

  /// Generate flashcards without streaming (simpler API)
  Future<List<Map<String, String>>> generateFlashcardsSync({
    required String topic,
    required int count,
    required String difficulty,
    required String contentType,
    String? goalContext,
    String? additionalContext,
    String? model,
  }) async {
    if (_client == null) {
      await init();
    }

    // Get model from config or use provided one
    final selectedModel =
        model ??
        await _configService.getLastUsedModel() ??
        await _configService.getDefaultModel() ??
        'llama3.2';

    // Build the prompt
    final prompt = _buildPrompt(
      topic: topic,
      count: count,
      difficulty: difficulty,
      contentType: contentType,
      goalContext: goalContext,
      additionalContext: additionalContext,
    );

    // Prepare messages
    final messages = [
      OllamaMessage.system(
        '''You are an expert educational content creator. 
Generate flashcards in a clear, structured format.
Always respond with the exact format requested.
Do not include any explanations or additional text outside the flashcard format.''',
      ),
      OllamaMessage.user(prompt),
    ];

    try {
      final response = await _client!.chat(selectedModel, messages);
      final cards = _parseFlashcards(response.message.content);

      // Save the model as last used
      await _configService.setLastUsedModel(selectedModel);

      return cards;
    } catch (e) {
      throw OllamaGenerationException(
        'Failed to generate flashcards: $e',
        originalError: e,
      );
    }
  }

  /// Build the generation prompt
  String _buildPrompt({
    required String topic,
    required int count,
    required String difficulty,
    required String contentType,
    String? goalContext,
    String? additionalContext,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
      'Generate $count $contentType for learning about "$topic" at $difficulty level.',
    );
    buffer.writeln();

    if (goalContext != null) {
      buffer.writeln('Goal context: $goalContext');
    }

    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer.writeln('Additional context: $additionalContext');
    }

    buffer.writeln();
    buffer.writeln('Format each item EXACTLY as:');
    buffer.writeln('Front: [question/term/prompt]');
    buffer.writeln('Back: [answer/definition/response]');
    buffer.writeln();
    buffer.writeln('Requirements:');
    buffer.writeln('- Provide exactly $count items');
    buffer.writeln('- Each item must be clearly separated');
    buffer.writeln(
      '- Use simple, clear language appropriate for $difficulty level learners',
    );
    buffer.writeln('- Do not include item numbers or extra formatting');
    buffer.writeln(
      '- Do not include any explanations before or after the items',
    );

    return buffer.toString();
  }

  /// Parse generated content into flashcards
  List<Map<String, String>> _parseFlashcards(String content) {
    final cards = <Map<String, String>>[];
    final lines = content.split('\n');

    String? currentFront;
    String? currentBack;

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      if (trimmedLine.toLowerCase().startsWith('front:')) {
        // Save previous card if exists
        if (currentFront != null && currentBack != null) {
          cards.add({'front': currentFront, 'back': currentBack});
        }
        currentFront = trimmedLine.substring(6).trim();
        currentBack = null;
      } else if (trimmedLine.toLowerCase().startsWith('back:')) {
        currentBack = trimmedLine.substring(5).trim();
      } else if (currentFront != null && currentBack == null) {
        // Continue front content
        currentFront = '$currentFront $trimmedLine';
      } else if (currentBack != null) {
        // Continue back content
        currentBack = '$currentBack $trimmedLine';
      }
    }

    // Add last card
    if (currentFront != null && currentBack != null) {
      cards.add({'front': currentFront, 'back': currentBack});
    }

    // If parsing failed, try alternative format (numbered)
    if (cards.isEmpty) {
      cards.addAll(_parseAlternativeFormat(content));
    }

    return cards;
  }

  /// Parse alternative format (e.g., "1. Term - Definition")
  List<Map<String, String>> _parseAlternativeFormat(String content) {
    final cards = <Map<String, String>>[];
    final regex = RegExp(r'^\d+\.\s*(.+?)\s*[-:]\s*(.+)$', multiLine: true);
    final matches = regex.allMatches(content);

    for (final match in matches) {
      if (match.groupCount >= 2) {
        cards.add({
          'front': match.group(1)?.trim() ?? '',
          'back': match.group(2)?.trim() ?? '',
        });
      }
    }

    return cards;
  }
}

/// Exception thrown when flashcard generation fails
class OllamaGenerationException implements Exception {
  final String message;
  final dynamic originalError;

  OllamaGenerationException(this.message, {this.originalError});

  @override
  String toString() => 'OllamaGenerationException: $message';
}
