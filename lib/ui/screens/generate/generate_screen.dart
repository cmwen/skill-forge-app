import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../services/services.dart';
import '../../theme/app_theme.dart';
import '../goals/create_goal_screen.dart';
import '../deck/deck_detail_screen.dart';

/// Screen for generating content with AI assistance.
///
/// Implements the goal-first content generation workflow:
/// 1. Select learning goal
/// 2. Define topic & parameters
/// 3. Generate prompt
/// 4. Share to LLM / Paste content
/// 5. Preview & Save
class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  // Step tracking
  int _currentStep = 0;

  // Step 1: Goal selection
  String? _selectedGoalId;

  // Step 2: Topic parameters
  final _topicController = TextEditingController();
  final _contextController = TextEditingController();
  int _itemCount = 20;
  String _difficulty = 'Intermediate';
  String _contentType = 'Flashcards';

  // Step 3: Generated prompt
  String _generatedPrompt = '';

  // Step 4: Paste content
  final _pasteController = TextEditingController();

  // Step 5: Parsed cards
  List<Map<String, String>> _parsedCards = [];
  final _deckNameController = TextEditingController();

  // Ollama integration
  OllamaGenerationService? _ollamaService;
  bool _isGenerating = false;
  String _generationProgress = '';
  bool _ollamaAvailable = false;

  @override
  void initState() {
    super.initState();
    _initOllama();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().loadGoals();
      
      // Check if we received a goal ID as argument
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _selectedGoalId = args;
          _currentStep = 1; // Skip to topic parameters
        });
      }
    });
  }

  Future<void> _initOllama() async {
    try {
      _ollamaService = OllamaGenerationService();
      await _ollamaService!.init();
      final available = await _ollamaService!.isAvailable();
      setState(() {
        _ollamaAvailable = available;
      });
    } catch (e) {
      // Ollama not available, user can still use manual workflow
      setState(() {
        _ollamaAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    _contextController.dispose();
    _pasteController.dispose();
    _deckNameController.dispose();
    super.dispose();
  }

  void _generatePrompt() {
    final goalsProvider = context.read<GoalsProvider>();
    final goal = goalsProvider.getGoalById(_selectedGoalId!);

    final prompt = '''Generate $_itemCount $_contentType for learning about "${_topicController.text.trim()}" at $_difficulty level.

Goal context: ${goal?.name ?? 'Learning'}
${_contextController.text.trim().isNotEmpty ? 'Additional context: ${_contextController.text.trim()}' : ''}

Format each item as:
Front: [question/term/prompt]
Back: [answer/definition/response]

Please provide exactly $_itemCount items, each clearly separated.
Use simple, clear language appropriate for $_difficulty level learners.''';

    setState(() {
      _generatedPrompt = prompt;
      _currentStep = 2;
    });
  }

  Future<void> _sharePrompt() async {
    await Share.share(_generatedPrompt, subject: 'Generate Learning Content');
  }

  void _copyPrompt() {
    Clipboard.setData(ClipboardData(text: _generatedPrompt));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt copied to clipboard')),
    );
  }

  /// Generate content directly using Ollama (new workflow)
  Future<void> _generateWithOllama() async {
    if (_ollamaService == null || !_ollamaAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ollama is not available. Please check your Ollama server.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationProgress = '';
    });

    try {
      final goalsProvider = context.read<GoalsProvider>();
      final goal = goalsProvider.getGoalById(_selectedGoalId!);

      final cards = await _ollamaService!.generateFlashcards(
        topic: _topicController.text.trim(),
        count: _itemCount,
        difficulty: _difficulty,
        contentType: _contentType,
        goalContext: goal?.name,
        additionalContext: _contextController.text.trim().isNotEmpty
            ? _contextController.text.trim()
            : null,
        onProgress: (progress) {
          setState(() {
            _generationProgress += progress;
          });
        },
      );

      setState(() {
        _isGenerating = false;
        _parsedCards = cards;
        _deckNameController.text = _topicController.text.trim();
        _currentStep = 4; // Go to preview step
      });

      if (cards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No flashcards were generated. Please try again.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate content: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _parseContent() {
    final content = _pasteController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste the LLM response')),
      );
      return;
    }

    // Simple parsing logic - looks for "Front:" and "Back:" patterns
    final cards = <Map<String, String>>[];
    final lines = content.split('\n');

    String? currentFront;
    String? currentBack;

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.toLowerCase().startsWith('front:')) {
        // Save previous card if exists
        if (currentFront != null && currentBack != null) {
          cards.add({'front': currentFront, 'back': currentBack});
        }
        currentFront = trimmedLine.substring(6).trim();
        currentBack = null;
      } else if (trimmedLine.toLowerCase().startsWith('back:')) {
        currentBack = trimmedLine.substring(5).trim();
      } else if (currentFront != null && currentBack == null && trimmedLine.isNotEmpty) {
        // Continue front content
        currentFront = '$currentFront $trimmedLine';
      } else if (currentBack != null && trimmedLine.isNotEmpty) {
        // Continue back content
        currentBack = '$currentBack $trimmedLine';
      }
    }

    // Add last card
    if (currentFront != null && currentBack != null) {
      cards.add({'front': currentFront, 'back': currentBack});
    }

    if (cards.isEmpty) {
      // Try alternative parsing (numbered format)
      _parseAlternativeFormat(content, cards);
    }

    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not parse content. Please check the format.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _parsedCards = cards;
      _deckNameController.text = _topicController.text.trim();
      _currentStep = 4;
    });
  }

  void _parseAlternativeFormat(String content, List<Map<String, String>> cards) {
    // Try parsing numbered format like "1. Term - Definition"
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
  }

  Future<void> _saveCards() async {
    if (_parsedCards.isEmpty) return;

    try {
      // Create deck
      final deck = await context.read<DecksProvider>().createDeck(
            goalId: _selectedGoalId!,
            name: _deckNameController.text.trim(),
            source: 'AI Generated',
          );

      // Load flashcards provider for this deck
      final flashcardsProvider = context.read<FlashcardsProvider>();
      await flashcardsProvider.loadFlashcardsForDeck(deck.id);

      // Add all cards
      await flashcardsProvider.createFlashcards(
        deckId: deck.id,
        cardData: _parsedCards,
      );

      // Refresh stats
      await context.read<GoalsProvider>().refreshGoalStats(_selectedGoalId!);

      if (mounted) {
        _showSuccessDialog(deck);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save cards: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(Deck deck) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: AppSpacing.s),
            Text('Content Added!'),
          ],
        ),
        content: Text(
          '${_parsedCards.length} cards added to "${deck.name}"',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Add More'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeckDetailScreen(
                    deckId: deck.id,
                    goalId: deck.goalId,
                  ),
                ),
              );
              _resetForm();
            },
            child: const Text('Start Practicing'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _selectedGoalId = null;
      _topicController.clear();
      _contextController.clear();
      _itemCount = 20;
      _difficulty = 'Intermediate';
      _contentType = 'Flashcards';
      _generatedPrompt = '';
      _pasteController.clear();
      _parsedCards = [];
      _deckNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Content'),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _resetForm,
              child: const Text('Start Over'),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentStep,
        children: [
          _buildStep1GoalSelection(),
          _buildStep2TopicParameters(),
          _buildStep3PromptReady(),
          _buildStep4PasteContent(),
          _buildStep5Preview(),
        ],
      ),
    );
  }

  Widget _buildStep1GoalSelection() {
    return Consumer<GoalsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.goals.isEmpty) {
          return Center(
            child: Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined,
                      size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'No Learning Goals Yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  const Text(
                    'Create a learning goal first to organize your content.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.l),
                  FilledButton(
                    onPressed: () async {
                      // Navigate to create goal screen
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateGoalScreen(),
                        ),
                      );
                      // Reload goals after returning
                      if (mounted) {
                        await context.read<GoalsProvider>().loadGoals();
                      }
                    },
                    child: const Text('Create a Goal'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: AppSpacing.screenPadding,
          children: [
            Text(
              'Which goal is this content for?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            ...provider.goals.map((goal) {
              final stats = provider.getStatsForGoal(goal.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s),
                child: Card(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedGoalId = goal.id;
                        _currentStep = 1;
                      });
                    },
                    borderRadius: AppRadius.mediumBorderRadius,
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Row(
                        children: [
                          Text(goal.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: AppSpacing.m),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.name,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${stats?.deckCount ?? 0} decks • ${stats?.cardCount ?? 0} cards',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.m),
            OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGoalScreen(),
                  ),
                );
                // Reload goals after returning
                if (mounted) {
                  await context.read<GoalsProvider>().loadGoals();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Goal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep2TopicParameters() {
    if (_selectedGoalId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final goal = context.read<GoalsProvider>().getGoalById(_selectedGoalId!);

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Goal context
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mediumBorderRadius,
          ),
          child: Row(
            children: [
              Text(goal?.icon ?? '📚', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  'Goal: ${goal?.name ?? ''}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Topic
        const Text('What specific topic?'),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _topicController,
          decoration: const InputDecoration(
            hintText: 'e.g., Dialogue from episode 10',
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Number of items
        const Text('Number of items'),
        const SizedBox(height: AppSpacing.s),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 10, label: Text('10')),
            ButtonSegment(value: 20, label: Text('20')),
            ButtonSegment(value: 50, label: Text('50')),
          ],
          selected: {_itemCount},
          onSelectionChanged: (value) =>
              setState(() => _itemCount = value.first),
        ),
        const SizedBox(height: AppSpacing.l),

        // Difficulty
        const Text('Difficulty level'),
        const SizedBox(height: AppSpacing.s),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Beginner', label: Text('Beginner')),
            ButtonSegment(value: 'Intermediate', label: Text('Intermediate')),
            ButtonSegment(value: 'Advanced', label: Text('Advanced')),
          ],
          selected: {_difficulty},
          onSelectionChanged: (value) =>
              setState(() => _difficulty = value.first),
        ),
        const SizedBox(height: AppSpacing.l),

        // Content type
        const Text('Content type'),
        const SizedBox(height: AppSpacing.s),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Flashcards', label: Text('Flashcards')),
            ButtonSegment(value: 'Q&A', label: Text('Q&A')),
            ButtonSegment(value: 'Vocabulary', label: Text('Vocabulary')),
          ],
          selected: {_contentType},
          onSelectionChanged: (value) =>
              setState(() => _contentType = value.first),
        ),
        const SizedBox(height: AppSpacing.l),

        // Additional context
        const Text('Additional context (optional)'),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _contextController,
          decoration: const InputDecoration(
            hintText: 'e.g., Focus on common phrases',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Generate buttons
        if (_ollamaAvailable) ...[
          // Direct Ollama generation
          FilledButton.icon(
            onPressed: _topicController.text.trim().isNotEmpty && !_isGenerating
                ? _generateWithOllama
                : null,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Generating...' : 'Generate with Ollama'),
          ),
          const SizedBox(height: AppSpacing.m),
          
          // Show generation progress
          if (_isGenerating && _generationProgress.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.mediumBorderRadius,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        'Generating content...',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _generationProgress,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.m),
          
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Text('OR'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        
        // Manual prompt generation (fallback)
        OutlinedButton(
          onPressed: _topicController.text.trim().isNotEmpty
              ? _generatePrompt
              : null,
          child: Text(_ollamaAvailable 
              ? 'Generate Manual Prompt' 
              : 'Generate Prompt'),
        ),
        
        // Ollama status indicator
        if (!_ollamaAvailable && _ollamaService != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.m),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: AppRadius.smallBorderRadius,
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, 
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'Ollama not available. Using manual workflow.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildStep3PromptReady() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Your prompt is ready!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.m),

        // Prompt display
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mediumBorderRadius,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _generatedPrompt,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _copyPrompt,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Share button
        FilledButton.icon(
          onPressed: _sharePrompt,
          icon: const Icon(Icons.share),
          label: const Text('Share to LLM App'),
        ),
        const SizedBox(height: AppSpacing.m),

        const Divider(),
        const SizedBox(height: AppSpacing.m),

        Text(
          'Or paste content if ready:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.s),
        OutlinedButton(
          onPressed: () => setState(() => _currentStep = 3),
          child: const Text('Paste Content'),
        ),
      ],
    );
  }

  Widget _buildStep4PasteContent() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        Text(
          'Paste the LLM response here:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.m),
        TextField(
          controller: _pasteController,
          decoration: const InputDecoration(
            hintText: 'Paste content here...',
          ),
          maxLines: 12,
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: FilledButton(
                onPressed: _parseContent,
                child: const Text('Parse & Preview'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5Preview() {
    if (_selectedGoalId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final goal = context.read<GoalsProvider>().getGoalById(_selectedGoalId!);

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        // Success header
        Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: AppSpacing.s),
            Text(
              '${_parsedCards.length} flashcards detected',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),

        // Preview cards (show first 3)
        Text(
          'Preview:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.s),
        ..._parsedCards.take(3).map((card) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Front: ${card['front']}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Back: ${card['back']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        if (_parsedCards.length > 3)
          Text(
            '... and ${_parsedCards.length - 3} more cards',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.l),

        // Save to
        Text(
          'Save to:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.s),
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.mediumBorderRadius,
          ),
          child: Row(
            children: [
              Text(goal?.icon ?? '📚', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.s),
              Text('Goal: ${goal?.name ?? ''}'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        // Deck name
        const Text('Deck name:'),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _deckNameController,
          decoration: const InputDecoration(
            hintText: 'Enter deck name',
          ),
        ),
        const SizedBox(height: AppSpacing.l),

        // Save button
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 3),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: FilledButton(
                onPressed: _deckNameController.text.trim().isNotEmpty
                    ? _saveCards
                    : null,
                child: const Text('Save to Goal'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}
