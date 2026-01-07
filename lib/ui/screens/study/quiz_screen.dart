import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

/// Screen for quiz mode with multiple choice questions.
class QuizScreen extends StatefulWidget {
  final String deckId;
  final String goalId;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.deckId,
    required this.goalId,
    this.questionCount = 10,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Flashcard> _allCards = [];
  List<Flashcard> _quizCards = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedAnswer;
  bool _showingResult = false;
  bool _quizComplete = false;
  List<int> _currentOptions = []; // Indices into _allCards

  @override
  void initState() {
    super.initState();
    _setupQuiz();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  void _setupQuiz() {
    final flashcardsProvider = context.read<FlashcardsProvider>();
    _allCards = List.from(flashcardsProvider.flashcards);
    
    // Select cards for the quiz
    final available = List<Flashcard>.from(_allCards);
    available.shuffle();
    _quizCards = available.take(widget.questionCount).toList();
    
    _generateOptions();
  }

  void _generateOptions() {
    if (_currentIndex >= _quizCards.length) return;
    
    final correctCard = _quizCards[_currentIndex];
    final correctIndex = _allCards.indexOf(correctCard);
    
    // Get 3 wrong answers
    final wrongIndices = <int>[];
    final availableIndices = List<int>.generate(_allCards.length, (i) => i)
      ..remove(correctIndex);
    availableIndices.shuffle();
    
    for (var i = 0; i < min(3, availableIndices.length); i++) {
      wrongIndices.add(availableIndices[i]);
    }
    
    // Combine and shuffle
    _currentOptions = [correctIndex, ...wrongIndices];
    _currentOptions.shuffle();
  }

  void _startSession() {
    context.read<StudyProvider>().startSession(
          goalId: widget.goalId,
          deckId: widget.deckId,
          sessionType: StudySessionType.quiz,
        );
  }

  void _selectAnswer(int optionIndex) {
    if (_showingResult) return;
    
    final correctCard = _quizCards[_currentIndex];
    final selectedCardIndex = _currentOptions[optionIndex];
    final isCorrect = _allCards[selectedCardIndex].id == correctCard.id;

    setState(() {
      _selectedAnswer = optionIndex;
      _showingResult = true;
    });

    // Record in study session
    context.read<StudyProvider>().recordCardReview(wasCorrect: isCorrect);

    // Update flashcard stats
    context.read<FlashcardsProvider>().recordReview(
          correctCard.id,
          isCorrect ? 2 : 0, // Easy if correct, Hard if wrong
        );

    if (isCorrect) {
      _correctCount++;
    }
  }

  void _nextQuestion() {
    setState(() {
      _selectedAnswer = null;
      _showingResult = false;
      
      if (_currentIndex < _quizCards.length - 1) {
        _currentIndex++;
        _generateOptions();
      } else {
        _quizComplete = true;
        _endSession();
      }
    });
  }

  Future<void> _endSession() async {
    if (!mounted) return;
    
    await context.read<StudyProvider>().endSession();
    
    if (!mounted) return;
    
    await context.read<DecksProvider>().refreshDeckStats(widget.deckId);
    
    if (!mounted) return;
    
    await context.read<GoalsProvider>().refreshGoalStats(widget.goalId);
    
    if (!mounted) return;
    
    // Refresh flashcards to reflect updated mastery levels
    await context.read<FlashcardsProvider>().refresh();
    
    if (!mounted) return;
    
    // Refresh overall stats for the progress screen
    await context.read<StudyProvider>().refreshOverallStats();
    
    if (!mounted) return;
    
    await context.read<DecksProvider>().markDeckStudied(widget.deckId);
    
    if (!mounted) return;
    
    await context.read<GoalsProvider>().markGoalStudied(widget.goalId);
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Quiz?'),
        content: const Text('Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // End the session
              if (mounted) {
                await _endSession();
              }
              // Pop the quiz screen after session ends
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('End Quiz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const EmptyStateWidget(
          icon: Icons.quiz,
          title: 'Not Enough Cards',
          description: 'You need at least 4 cards to start a quiz.',
        ),
      );
    }

    if (_quizComplete) {
      return _buildQuizSummary();
    }

    final currentCard = _quizCards[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Question ${_currentIndex + 1}/${_quizCards.length}'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _quizCards.length,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Question
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.l),
                    child: Column(
                      children: [
                        Text(
                          'What is the answer for:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          currentCard.front,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Options
                Expanded(
                  child: ListView.separated(
                    itemCount: _currentOptions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final cardIndex = _currentOptions[index];
                      final optionCard = _allCards[cardIndex];
                      final isCorrectAnswer =
                          optionCard.id == currentCard.id;
                      final isSelected = _selectedAnswer == index;

                      Color? backgroundColor;
                      Color? borderColor;
                      
                      if (_showingResult) {
                        if (isCorrectAnswer) {
                          backgroundColor = AppColors.success.withValues(alpha: 0.2);
                          borderColor = AppColors.success;
                        } else if (isSelected) {
                          backgroundColor = AppColors.error.withValues(alpha: 0.2);
                          borderColor = AppColors.error;
                        }
                      }

                      return Material(
                        color: backgroundColor ?? AppColors.surface,
                        borderRadius: AppRadius.mediumBorderRadius,
                        child: InkWell(
                          onTap: _showingResult ? null : () => _selectAnswer(index),
                          borderRadius: AppRadius.mediumBorderRadius,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.m),
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.mediumBorderRadius,
                              border: Border.all(
                                color: borderColor ?? AppColors.border,
                                width: borderColor != null ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected && _showingResult
                                        ? (isCorrectAnswer
                                            ? AppColors.success
                                            : AppColors.error)
                                        : AppColors.card,
                                  ),
                                  child: Center(
                                    child: _showingResult && isCorrectAnswer
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 20)
                                        : _showingResult &&
                                                isSelected &&
                                                !isCorrectAnswer
                                            ? const Icon(Icons.close,
                                                color: Colors.white, size: 20)
                                            : Text(
                                                String.fromCharCode(
                                                    65 + index), // A, B, C, D
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.m),
                                Expanded(
                                  child: Text(
                                    optionCard.back,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Next button (shown after answering)
                if (_showingResult)
                  FilledButton(
                    onPressed: _nextQuestion,
                    child: Text(
                      _currentIndex < _quizCards.length - 1
                          ? 'Next Question'
                          : 'See Results',
                    ),
                  ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizSummary() {
    final totalQuestions = _quizCards.length;
    final accuracy =
        totalQuestions > 0 ? (_correctCount / totalQuestions) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Complete'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                accuracy >= 80
                    ? Icons.emoji_events
                    : accuracy >= 60
                        ? Icons.thumb_up
                        : Icons.trending_up,
                size: 64,
                color: accuracy >= 80
                    ? AppColors.success
                    : accuracy >= 60
                        ? AppColors.warning
                        : AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                accuracy >= 80
                    ? 'Excellent!'
                    : accuracy >= 60
                        ? 'Good Job!'
                        : 'Keep Practicing!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.l),

              // Score display
              Text(
                '${accuracy.toInt()}%',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: accuracy >= 80
                          ? AppColors.success
                          : accuracy >= 60
                              ? AppColors.warning
                              : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.m),

              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Correct',
                        value: '$_correctCount / $totalQuestions',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Return to Deck'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex = 0;
                          _correctCount = 0;
                          _selectedAnswer = null;
                          _showingResult = false;
                          _quizComplete = false;
                          _setupQuiz();
                          _startSession();
                        });
                      },
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
