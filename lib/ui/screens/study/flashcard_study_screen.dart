import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

/// Screen for studying flashcards with spaced repetition.
class FlashcardStudyScreen extends StatefulWidget {
  final String deckId;
  final String goalId;
  final bool dueOnly;

  const FlashcardStudyScreen({
    super.key,
    required this.deckId,
    required this.goalId,
    this.dueOnly = false,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _showingFront = true;
  int _correctCount = 0;
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSession();
    });
  }

  void _loadCards() {
    final flashcardsProvider = context.read<FlashcardsProvider>();
    if (widget.dueOnly) {
      _cards = flashcardsProvider.dueFlashcards;
      if (_cards.isEmpty) {
        _cards = flashcardsProvider.unmasteredFlashcards;
      }
    } else {
      _cards = flashcardsProvider.getShuffledFlashcards();
    }
  }

  void _startSession() {
    context.read<StudyProvider>().startSession(
      goalId: widget.goalId,
      deckId: widget.deckId,
      sessionType: StudySessionType.flashcards,
    );
  }

  void _flipCard() {
    setState(() {
      _showingFront = !_showingFront;
    });

    // Speak the revealed side if TTS auto-play is enabled
    if (!_showingFront) {
      final prefs = context.read<PreferencesService>();
      final tts = context.read<TtsService>();
      if (prefs.isTtsAutoPlayEnabled()) {
        final card = _cards[_currentIndex];
        tts.speak(card.back);
      }
    }
  }

  Future<void> _rateCard(int quality) async {
    if (_currentIndex >= _cards.length) return;
    final card = _cards[_currentIndex];
    final wasCorrect = quality >= 1;

    // Record in provider
    final flashcardsProvider = context.read<FlashcardsProvider>();
    final studyProvider = context.read<StudyProvider>();

    await flashcardsProvider.recordReview(card.id, quality);

    // Track in study session
    studyProvider.recordCardReview(wasCorrect: wasCorrect);

    if (wasCorrect) {
      _correctCount++;
    }

    // Move to next card or end session
    setState(() {
      _showingFront = true;
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
      } else {
        _sessionComplete = true;
        _endSession();
      }
    });
  }

  Future<void> _endSession() async {
    if (!mounted) return;

    await context.read<StudyProvider>().endSession();

    if (!mounted) return;

    // Refresh stats
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

    // Mark deck as studied
    await context.read<DecksProvider>().markDeckStudied(widget.deckId);

    if (!mounted) return;

    await context.read<GoalsProvider>().markGoalStudied(widget.goalId);
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Session?'),
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
              // Pop the study screen after session ends
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: EmptyStates.allCaughtUp(onPractice: () => Navigator.pop(context)),
      );
    }

    if (_sessionComplete) {
      return _buildSessionSummary();
    }

    final currentCard = _cards[_currentIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                // Progress indicator
                StudyProgressIndicator(
                  currentCard: _currentIndex + 1,
                  totalCards: _cards.length,
                  correctCount: _correctCount,
                ),
                const SizedBox(height: AppSpacing.l),

                // Flashcard
                Expanded(
                  child: FlashcardWidget(
                    front: currentCard.front,
                    back: currentCard.back,
                    notes: currentCard.notes,
                    showingFront: _showingFront,
                    onTap: _flipCard,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),

                // TTS button
                Consumer2<PreferencesService, TtsService>(
                  builder: (context, prefs, tts, _) {
                    if (!prefs.isTtsEnabled()) return const SizedBox.shrink();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          onPressed: () {
                            final text = _showingFront
                                ? currentCard.front
                                : currentCard.back;
                            tts.speak(text);
                          },
                          icon: Icon(
                            tts.isSpeaking
                                ? Icons.volume_up
                                : Icons.volume_up_outlined,
                          ),
                          tooltip: 'Speak',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.m),

                // Rating buttons (show only when card is flipped)
                if (!_showingFront)
                  ReviewRatingButtons(onRating: _rateCard)
                else
                  const SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        'Tap card to reveal answer',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
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

  Widget _buildSessionSummary() {
    final totalCards = _cards.length;
    final accuracy = totalCards > 0 ? (_correctCount / totalCards) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 64, color: AppColors.success),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Great Work!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.l),

              // Stats
              Card(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Cards Reviewed',
                        value: '$totalCards',
                      ),
                      _SummaryRow(
                        label: 'Correct',
                        value: '$_correctCount',
                        valueColor: AppColors.success,
                      ),
                      _SummaryRow(
                        label: 'Accuracy',
                        value: '${accuracy.toInt()}%',
                        valueColor: accuracy >= 80
                            ? AppColors.success
                            : accuracy >= 60
                            ? AppColors.warning
                            : AppColors.error,
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
                          _showingFront = true;
                          _sessionComplete = false;
                          _loadCards();
                          _startSession();
                        });
                      },
                      child: const Text('Study Again'),
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
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

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
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
