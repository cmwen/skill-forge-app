import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../study/flashcard_study_screen.dart';
import '../study/quiz_screen.dart';
import 'add_card_screen.dart';
import 'card_list_screen.dart';

/// Screen showing deck details and practice options.
class DeckDetailScreen extends StatefulWidget {
  final String deckId;
  final String goalId;

  const DeckDetailScreen({
    super.key,
    required this.deckId,
    required this.goalId,
  });

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardsProvider>().loadFlashcardsForDeck(widget.deckId);
    });
  }

  void _startFlashcardStudy({bool dueOnly = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardStudyScreen(
          deckId: widget.deckId,
          goalId: widget.goalId,
          dueOnly: dueOnly,
        ),
      ),
    );
  }

  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          deckId: widget.deckId,
          goalId: widget.goalId,
        ),
      ),
    );
  }

  void _navigateToAddCard() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCardScreen(deckId: widget.deckId),
      ),
    );
    if (result == true) {
      // Card was added, refresh the list
      context.read<FlashcardsProvider>().loadFlashcardsForDeck(widget.deckId);
      context.read<DecksProvider>().refreshDeckStats(widget.deckId);
      context.read<GoalsProvider>().refreshGoalStats(widget.goalId);
    }
  }

  void _viewAllCards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardListScreen(
          deckId: widget.deckId,
          goalId: widget.goalId,
        ),
      ),
    );
  }

  void _showDeckMenu() {
    final decksProvider = context.read<DecksProvider>();
    final deck = decksProvider.getDeckById(widget.deckId);
    if (deck == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Cards'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddCard();
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Generate More Content'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Generate screen with goal pre-selected
                context.read<NavigationProvider>().navigateToGenerate();
                // Pop back to main shell so we're at the Generate tab
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export Deck'),
              onTap: () {
                Navigator.pop(context);
                _showExportDeckOptions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Deck',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteDeck();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDeck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: const Text(
          'This will permanently delete this deck and all its cards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<DecksProvider>().deleteDeck(widget.deckId);
              await context
                  .read<GoalsProvider>()
                  .refreshGoalStats(widget.goalId);
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDeckOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                'Export Deck',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON (Full backup)'),
              subtitle: const Text('Complete data with progress'),
              onTap: () {
                Navigator.pop(context);
                _exportDeck(ExportFormat.json);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV (Anki/Quizlet compatible)'),
              subtitle: const Text('Cards only'),
              onTap: () {
                Navigator.pop(context);
                _exportDeck(ExportFormat.csv);
              },
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Future<void> _exportDeck(ExportFormat format) async {
    try {
      final exportService = context.read<ExportImportService>();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await exportService.exportDeckAndShare(
        deckId: widget.deckId,
        format: format,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export complete')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksProvider = context.watch<DecksProvider>();
    final flashcardsProvider = context.watch<FlashcardsProvider>();
    final deck = decksProvider.getDeckById(widget.deckId);

    if (deck == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Deck not found')),
      );
    }

    final cardCount = flashcardsProvider.cardCount;
    final masteredCount = flashcardsProvider.masteredCount;
    final dueCount = flashcardsProvider.dueFlashcards.length;
    final progressPercent = cardCount > 0 ? masteredCount / cardCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showDeckMenu,
          ),
        ],
      ),
      body: flashcardsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : flashcardsProvider.flashcards.isEmpty
              ? EmptyStates.noCards(onAdd: _navigateToAddCard)
              : ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    // Goal context
                    Consumer<GoalsProvider>(
                      builder: (context, goalsProvider, _) {
                        final goal = goalsProvider.getGoalById(widget.goalId);
                        if (goal == null) return const SizedBox.shrink();
                        return Text(
                          'Goal: ${goal.icon} ${goal.name}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Stats row
                    Text(
                      '$cardCount cards • $masteredCount mastered (${(progressPercent * 100).toInt()}%)',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Practice options section
                    Text(
                      'How do you want to practice?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Flashcards option
                    _PracticeOptionCard(
                      icon: Icons.style,
                      title: 'Flashcards',
                      subtitle: 'Classic card flipping',
                      actions: [
                        TextButton(
                          onPressed: () => _startFlashcardStudy(),
                          child: const Text('Study All'),
                        ),
                        if (dueCount > 0)
                          FilledButton(
                            onPressed: () => _startFlashcardStudy(dueOnly: true),
                            child: Text('Review Due ($dueCount)'),
                          )
                        else
                          FilledButton(
                            onPressed: () => _startFlashcardStudy(),
                            child: const Text('Review Unmastered'),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Quiz option
                    _PracticeOptionCard(
                      icon: Icons.quiz,
                      title: 'Quiz Mode',
                      subtitle: 'Test your knowledge',
                      actions: [
                        FilledButton(
                          onPressed: cardCount >= 4 ? _startQuiz : null,
                          child: const Text('Start Quiz'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Deck contents section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deck contents',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: _viewAllCards,
                          child: const Text('View All Cards'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Statistics
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Statistics',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.m),
                            _StatRow(
                              label: 'Mastery',
                              value: '$masteredCount/$cardCount cards (${(progressPercent * 100).toInt()}%)',
                            ),
                            _StatRow(
                              label: 'Created',
                              value: _formatDate(deck.createdAt),
                            ),
                            _StatRow(
                              label: 'Last studied',
                              value: deck.lastStudiedAt != null
                                  ? _formatDate(deck.lastStudiedAt!)
                                  : 'Never',
                            ),
                            _StatRow(
                              label: 'Total study time',
                              value: StudyProvider.formatDetailedDuration(
                                deck.totalStudyTimeSeconds,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddCard,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _PracticeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _PracticeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.s),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions
                  .expand((action) => [action, const SizedBox(width: AppSpacing.s)])
                  .take(actions.length * 2 - 1)
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
