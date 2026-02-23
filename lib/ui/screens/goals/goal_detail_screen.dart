import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../deck/deck_detail_screen.dart';
import '../deck/create_deck_screen.dart';
import '../stats/goal_stats_screen.dart';
import 'edit_goal_screen.dart';

/// Screen showing details of a learning goal and its decks.
class GoalDetailScreen extends StatefulWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DecksProvider>().loadDecksForGoal(widget.goalId);
    });
  }

  void _navigateToDeckDetail(String deckId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            DeckDetailScreen(deckId: deckId, goalId: widget.goalId),
      ),
    );
  }

  void _navigateToCreateDeck() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateDeckScreen(goalId: widget.goalId),
      ),
    );
  }

  void _navigateToGenerateContent() {
    // Navigate to the Generate screen (tab index 1) in the AppShell
    context.read<NavigationProvider>().navigateToGenerate();
  }

  void _showDeckOptions(String deckId) {
    final decksProvider = context.read<DecksProvider>();
    final deck = decksProvider.getDeckById(deckId);
    if (deck == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename Deck'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDeckDialog(deckId, deck.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export Deck'),
              onTap: () {
                Navigator.pop(context);
                _showExportDeckOptions(deckId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Deck',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteDeck(deckId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDeckDialog(String deckId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final decksProvider = context.read<DecksProvider>();
                final deck = decksProvider.getDeckById(deckId);
                if (deck != null) {
                  await decksProvider.updateDeck(deck.copyWith(name: newName));
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDeck(String deckId) {
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
            onPressed: () {
              Navigator.pop(context);
              context.read<DecksProvider>().deleteDeck(deckId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showGoalMenu() {
    final goalsProvider = context.read<GoalsProvider>();
    final goal = goalsProvider.getGoalById(widget.goalId);
    if (goal == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Goal'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditGoalScreen(goalId: widget.goalId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('View Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        GoalStatsScreen(goalId: widget.goalId),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export All Decks'),
              onTap: () {
                Navigator.pop(context);
                _exportGoal();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive Goal'),
              onTap: () {
                Navigator.pop(context);
                goalsProvider.archiveGoal(widget.goalId);
                Navigator.pop(context); // Go back to goals list
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete Goal',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteGoal();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGoal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text(
          'This will permanently delete this goal and all its decks and cards. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GoalsProvider>().deleteGoal(widget.goalId);
              Navigator.pop(context); // Go back to goals list
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDeckOptions(String deckId) {
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
                _exportDeck(deckId, ExportFormat.json);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV (Anki/Quizlet compatible)'),
              subtitle: const Text('Cards only'),
              onTap: () {
                Navigator.pop(context);
                _exportDeck(deckId, ExportFormat.csv);
              },
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Future<void> _exportDeck(String deckId, ExportFormat format) async {
    try {
      final exportService = context.read<ExportImportService>();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await exportService.exportDeckAndShare(deckId: deckId, format: format);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export complete')));
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

  Future<void> _exportGoal() async {
    try {
      final exportService = context.read<ExportImportService>();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await exportService.exportGoalAndShare(widget.goalId);

      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export complete')));
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
    final goalsProvider = context.watch<GoalsProvider>();
    final decksProvider = context.watch<DecksProvider>();
    final goal = goalsProvider.getGoalById(widget.goalId);
    final goalStats = goalsProvider.getStatsForGoal(widget.goalId);

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final progressPercent = goalStats != null && goalStats.cardCount > 0
        ? goalStats.masteredCount / goalStats.cardCount
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(goal.icon),
            const SizedBox(width: AppSpacing.s),
            Flexible(child: Text(goal.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showGoalMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 10,
                          backgroundColor: AppColors.progressBackground,
                          valueColor: AlwaysStoppedAnimation(
                            progressPercent >= 0.8
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Text(
                      '${(progressPercent * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${goalStats?.masteredCount ?? 0} / ${goalStats?.cardCount ?? 0} cards mastered',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Decks list
          Expanded(
            child: decksProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : decksProvider.decks.isEmpty
                ? EmptyStates.noDecks(
                    onGenerate: _navigateToGenerateContent,
                    onCreate: _navigateToCreateDeck,
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        decksProvider.loadDecksForGoal(widget.goalId),
                    child: ListView(
                      padding: AppSpacing.screenPadding,
                      children: [
                        Text(
                          'Decks in this goal',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        ...decksProvider.decks.map((deck) {
                          final stats = decksProvider.getStatsForDeck(deck.id);
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.s,
                            ),
                            child: DeckCard(
                              name: deck.name,
                              cardCount: stats?.cardCount ?? 0,
                              masteredCount: stats?.masteredCount ?? 0,
                              lastStudiedAt: deck.lastStudiedAt,
                              onTap: () => _navigateToDeckDetail(deck.id),
                              onPractice: () => _navigateToDeckDetail(deck.id),
                              onLongPress: () => _showDeckOptions(deck.id),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.m),
                        OutlinedButton.icon(
                          onPressed: _navigateToCreateDeck,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Deck'),
                        ),
                        const SizedBox(height: AppSpacing.s),
                        FilledButton.icon(
                          onPressed: _navigateToGenerateContent,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate Content with AI'),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
