import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

/// Screen showing learning progress across all goals.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final goalsProvider = context.read<GoalsProvider>();
    final studyProvider = context.read<StudyProvider>();
    
    await Future.wait([
      goalsProvider.loadGoals(),
      studyProvider.loadOverallStats(),
      studyProvider.loadRecentSessions(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () {
              // TODO: Export data
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Consumer2<GoalsProvider, StudyProvider>(
          builder: (context, goalsProvider, studyProvider, _) {
            if (goalsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final stats = studyProvider.overallStats;
            final totalCards = stats['total_cards'] ?? 0;
            final masteredCards = stats['mastered_cards'] ?? 0;
            final totalStudyTime = stats['total_study_time_seconds'] ?? 0;
            final todayStudyTime = stats['today_study_time'] ?? 0;
            final thisWeekStudyTime = stats['this_week_study_time'] ?? 0;

            return ListView(
              padding: AppSpacing.screenPadding,
              children: [
                // Overall Statistics
                Text(
                  'Overall Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Total study time',
                          value: StudyProvider.formatDetailedDuration(
                              totalStudyTime),
                        ),
                        _StatRow(
                          label: 'Total cards',
                          value: '$totalCards',
                        ),
                        _StatRow(
                          label: 'Cards mastered',
                          value: '$masteredCards (${totalCards > 0 ? ((masteredCards / totalCards) * 100).toInt() : 0}%)',
                          valueColor: AppColors.success,
                        ),
                        _StatRow(
                          label: 'Active goals',
                          value: '${goalsProvider.goals.length}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Goals Progress
                Text(
                  'Goals Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                if (goalsProvider.goals.isEmpty)
                  Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Text(
                        'No active goals yet. Create a goal to start tracking progress.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...goalsProvider.goals.map((goal) {
                    final goalStats = goalsProvider.getStatsForGoal(goal.id);
                    final cardCount = goalStats?.cardCount ?? 0;
                    final masteredCount = goalStats?.masteredCount ?? 0;
                    final progressPercent = goalStats?.progressPercent ?? 0.0;
                    final studyTime = goalStats?.totalStudyTimeSeconds ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s),
                      child: GoalProgressCard(
                        icon: goal.icon,
                        name: goal.name,
                        progressPercent: progressPercent,
                        cardsProgress: '$masteredCount/$cardCount cards',
                        studyTime: StudyProvider.formatDuration(studyTime),
                        onTap: () {
                          // TODO: Navigate to detailed goal stats
                        },
                      ),
                    );
                  }),
                const SizedBox(height: AppSpacing.l),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Today',
                          value:
                              StudyProvider.formatDetailedDuration(todayStudyTime),
                        ),
                        _StatRow(
                          label: 'This week',
                          value: StudyProvider.formatDetailedDuration(
                              thisWeekStudyTime),
                        ),
                        _StatRow(
                          label: 'This month',
                          value: StudyProvider.formatDetailedDuration(
                              totalStudyTime), // TODO: Calculate monthly
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Recent Sessions
                if (studyProvider.recentSessions.isNotEmpty) ...[
                  Text(
                    'Recent Sessions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  ...studyProvider.recentSessions.take(5).map((session) {
                    final goal = goalsProvider.getGoalById(session.goalId);
                    return Card(
                      child: ListTile(
                        leading: Text(goal?.icon ?? '📚',
                            style: const TextStyle(fontSize: 24)),
                        title: Text(goal?.name ?? 'Unknown Goal'),
                        subtitle: Text(
                          '${session.cardsReviewed} cards • ${session.accuracy.toInt()}% accuracy',
                        ),
                        trailing: Text(
                          _formatSessionTime(session.startedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatSessionTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
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
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
