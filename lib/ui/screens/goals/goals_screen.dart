import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/goals_provider.dart';
import '../../../services/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../goals/create_goal_screen.dart';
import '../goals/goal_detail_screen.dart';
import '../goals/edit_goal_screen.dart';
import '../goals/search_screen.dart';

/// The main Goals screen (home screen).
///
/// Displays all active learning goals with progress information.
/// Empty state shown for new users.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    // Load goals when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().loadGoals();
    });
  }

  void _navigateToCreateGoal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateGoalScreen(),
      ),
    );
  }

  void _navigateToGoalDetail(String goalId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goalId: goalId),
      ),
    );
  }

  void _showGoalOptions(String goalId) {
    final provider = context.read<GoalsProvider>();
    final goal = provider.getGoalById(goalId);
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
                    builder: (context) => EditGoalScreen(goalId: goalId),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                goal.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              title: Text(goal.isArchived ? 'Unarchive Goal' : 'Archive Goal'),
              onTap: () {
                Navigator.pop(context);
                if (goal.isArchived) {
                  provider.unarchiveGoal(goalId);
                } else {
                  provider.archiveGoal(goalId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Export Goal'),
              onTap: () {
                Navigator.pop(context);
                _exportGoal(goalId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Goal',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteGoal(goalId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteGoal(String goalId) {
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
              context.read<GoalsProvider>().deleteGoal(goalId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGoal(String goalId) async {
    try {
      final exportService = context.read<ExportImportService>();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await exportService.exportGoalAndShare(goalId);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.m),
                  Text(provider.error!),
                  const SizedBox(height: AppSpacing.m),
                  ElevatedButton(
                    onPressed: () => provider.loadGoals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.goals.isEmpty && !_showArchived) {
            return EmptyStates.noGoals(onCreate: _navigateToCreateGoal);
          }

          final goals = _showArchived ? provider.archivedGoals : provider.goals;

          return RefreshIndicator(
            onRefresh: () => provider.loadGoals(),
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Active goals section
                if (!_showArchived) ...[
                  Text(
                    'Active Goals',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                ],

                // Goal cards
                ...goals.map((goal) {
                  final stats = provider.getStatsForGoal(goal.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s),
                    child: GoalCard(
                      icon: goal.icon,
                      name: goal.name,
                      deckCount: stats?.deckCount ?? 0,
                      cardCount: stats?.cardCount ?? 0,
                      masteredCount: stats?.masteredCount ?? 0,
                      lastStudiedAt: goal.lastStudiedAt,
                      onTap: () => _navigateToGoalDetail(goal.id),
                      onLongPress: () => _showGoalOptions(goal.id),
                    ),
                  );
                }),

                // Archived section toggle
                if (provider.archivedGoals.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.m),
                  InkWell(
                    onTap: () => setState(() => _showArchived = !_showArchived),
                    borderRadius: AppRadius.smallBorderRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Completed Goals (${provider.archivedGoals.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            _showArchived
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Add button at bottom
                if (!_showArchived) ...[
                  const SizedBox(height: AppSpacing.m),
                  OutlinedButton.icon(
                    onPressed: _navigateToCreateGoal,
                    icon: const Icon(Icons.add),
                    label: const Text('New Learning Goal'),
                  ),
                ],

                // Bottom spacing
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateGoal,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}
