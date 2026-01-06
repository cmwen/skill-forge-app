# Ollama Integration Guide

## Overview

The app now includes full Ollama LLM integration for AI-powered flashcard generation. Users can generate flashcards directly within the app using local Ollama models without relying on external LLM services.

## Features Implemented

### 1. Ollama Generation Service (`lib/services/ollama_generation_service.dart`)

A dedicated service that bridges the Ollama toolkit with the flashcard generation workflow:

- **Model Management**: Automatically fetches available models from Ollama
- **Smart Prompt Building**: Creates optimized prompts for educational content generation
- **Streaming Support**: Real-time generation progress updates
- **Fallback Parsing**: Multiple parsing strategies for robustness
- **Configuration Persistence**: Remembers last used model

#### Key Methods:

```dart
// Check if Ollama is available
Future<bool> isAvailable()

// Get list of installed models
Future<List<OllamaModelInfo>> getAvailableModels()

// Generate flashcards with streaming progress
Future<List<Map<String, String>>> generateFlashcards({
  required String topic,
  required int count,
  required String difficulty,
  required String contentType,
  String? goalContext,
  String? additionalContext,
  String? model,
  required Function(String) onProgress,
})

// Generate flashcards without streaming (simpler)
Future<List<Map<String, String>>> generateFlashcardsSync(...)
```

### 2. Enhanced Generate Screen

The Generate Screen now offers two workflows:

#### Workflow A: Direct Ollama Generation (Recommended)
1. Select learning goal
2. Define topic and parameters
3. Click "Generate with Ollama" button
4. Watch real-time generation progress
5. Review and save generated flashcards

#### Workflow B: Manual Prompt (Fallback)
1. Select learning goal  
2. Define topic and parameters
3. Generate prompt
4. Copy/share to external LLM
5. Paste response back
6. Parse and save flashcards

### 3. User Experience Features

- **Auto-Detection**: Automatically detects if Ollama is available
- **Real-Time Progress**: Shows generation progress as LLM generates content
- **Graceful Degradation**: Falls back to manual workflow if Ollama is unavailable
- **Status Indicators**: Clear visual feedback about Ollama availability
- **Smart Parsing**: Handles multiple response formats from different models

## Setup Instructions

### For Users

1. **Install Ollama**: 
   - Download from [ollama.ai](https://ollama.ai)
   - Run `ollama serve` to start the server

2. **Pull a Model**:
   ```bash
   ollama pull llama3.2
   # or
   ollama pull mistral
   ```

3. **Use the App**:
   - Open the Generate screen
   - Select your learning goal
   - Define your topic
   - Click "Generate with Ollama"
   - Watch as flashcards are created in real-time!

### For Developers

The integration uses the existing `ollama_toolkit` package structure:

```
lib/
├── ollama_toolkit/          # Reusable Ollama integration
│   ├── models/              # Data models
│   ├── services/            # API client & config
│   └── thinking_loop/       # Agent framework (future)
├── services/
│   └── ollama_generation_service.dart  # Flashcard-specific service
└── ui/screens/generate/
    └── generate_screen.dart            # Enhanced with Ollama
```

## Configuration

The service uses `OllamaConfigService` to persist settings:

- **Base URL**: Default `http://localhost:11434`
- **Timeout**: Default 60 seconds
- **Last Used Model**: Automatically remembered
- **Model History**: Recent models tracked

## Error Handling

The integration handles common scenarios:

1. **Ollama Not Running**: Shows warning, enables manual workflow
2. **No Models Installed**: Prompts user to pull models
3. **Generation Timeout**: Graceful error with retry option
4. **Invalid Response Format**: Multiple parsing strategies
5. **Network Issues**: Clear error messages with troubleshooting hints

## Prompt Engineering

The service uses an optimized prompt structure:

```
Generate [count] [type] for learning about "[topic]" at [difficulty] level.

Goal context: [goal name]
Additional context: [user context]

Format each item EXACTLY as:
Front: [question/term/prompt]
Back: [answer/definition/response]

Requirements:
- Provide exactly [count] items
- Each item must be clearly separated
- Use simple, clear language appropriate for [difficulty] level learners
- Do not include item numbers or extra formatting
- Do not include any explanations before or after the items
```

## Future Enhancements

Potential improvements for future releases:

1. **Model Selection UI**: Let users choose from available models
2. **Advanced Settings**: Temperature, context length, system prompts
3. **Batch Generation**: Generate multiple decks at once
4. **Smart Retry**: Auto-retry with adjusted parameters if generation fails
5. **Quality Scoring**: Rate generated flashcards for quality
6. **Learning from Feedback**: Improve prompts based on user edits
7. **Multi-Modal Support**: Generate flashcards with images using vision models
8. **Agent Tools**: Use the thinking loop framework for complex generation tasks

## Troubleshooting

### Ollama Not Detected

1. Verify Ollama is running: `ollama list`
2. Check the base URL matches: `http://localhost:11434`
3. Ensure no firewall is blocking port 11434
4. Try restarting the Ollama service

### Poor Generation Quality

1. Try a different model (llama3.2, mistral, etc.)
2. Adjust the difficulty level
3. Provide more context in the "Additional context" field
4. Use smaller batch sizes (10-20 instead of 50)

### Generation Timeout

1. Reduce the number of items to generate
2. Check system resources (CPU/RAM)
3. Use a smaller/faster model
4. Increase timeout in settings (future feature)

## Testing

The integration includes comprehensive test coverage:

- Unit tests for parsing logic
- Integration tests with mock Ollama responses
- UI tests for the generate workflow

Run tests:
```bash
flutter test test/services/ollama_generation_service_test.dart
```

## Performance Notes

- **Streaming**: ~100-200ms per card (depending on model)
- **Batch**: 20 flashcards typically take 20-40 seconds
- **Memory**: ~2-4GB RAM (model dependent)
- **CPU**: Utilizes available cores for faster generation

## Credits

Built on top of the `ollama_toolkit` package which provides:
- Full Ollama API client
- Model registry with capabilities
- LangChain-inspired agent framework
- Configuration management
