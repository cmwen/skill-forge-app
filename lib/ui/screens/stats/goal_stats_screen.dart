import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Screen showing detailed statistics for a specific goal.
class GoalStatsScreen extends StatefulWidget {
  final String goalId;

  const GoalStatsScreen({super.key, required this.goalId});

  @override
  State<GoalStatsScreen> createState() => _GoalStatsScreenState();
}

class _GoalStatsScreenState extends State<GoalStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final studyProvider = context.read<StudyProvider>();
    await studyProvider.loadStatsForGoal(widget.goalId);
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = context.watch<GoalsProvider>();
    final studyProvider = context.watch<StudyProvider>();
    final goal = goalsProvider.getGoalById(widget.goalId);
    final goalStats = goalsProvider.getStatsForGoal(widget.goalId);

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Goal not found')),
      );
    }

    final cardCount = goalStats?.cardCount ?? 0;
    final masteredCount = goalStats?.masteredCount ?? 0;
    final deckCount = goalStats?.deckCount ?? 0;
    final totalStudyTime = goalStats?.totalStudyTimeSeconds ?? 0;
    final progressPercent = goalStats?.progressPercent ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${goal.icon} ${goal.name}'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Progress Overview
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Overview',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    // Circular progress indicator
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: CircularProgressIndicator(
                                value: progressPercent,
                                strokeWidth: 12,
                                backgroundColor: AppColors.surface,
                                color: _getProgressColor(progressPercent),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(progressPercent * 100).toInt()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Mastered',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    _StatRow(label: 'Total Decks', value: '$deckCount'),
                    _StatRow(label: 'Total Cards', value: '$cardCount'),
                    _StatRow(
                      label: 'Mastered Cards',
                      value: '$masteredCount',
                      valueColor: AppColors.success,
                    ),
                    _StatRow(
                      label: 'Learning Cards',
                      value: '${cardCount - masteredCount}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Study Time
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _StatRow(
                      label: 'Total Study Time',
                      value: StudyProvider.formatDetailedDuration(totalStudyTime),
                    ),
                    _StatRow(
                      label: 'Average per Session',
                      value: _calculateAvgSessionTime(studyProvider),
                    ),
                    _StatRow(
                      label: 'Total Sessions',
                      value: '${studyProvider.goalSessions.length}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Goal Info
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goal Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _StatRow(
                      label: 'Created',
                      value: _formatDate(goal.createdAt),
                    ),
                    if (goal.targetDate != null)
                      _StatRow(
                        label: 'Target Date',
                        value: _formatDate(goal.targetDate!),
                        valueColor: goal.targetDate!.isBefore(DateTime.now())
                            ? AppColors.error
                            : null,
                      ),
                    if (goal.lastStudiedAt != null)
                      _StatRow(
                        label: 'Last Studied',
                        value: _formatRelativeDate(goal.lastStudiedAt!),
                      ),
                    if (goal.description != null &&
                        goal.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(goal.description!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Recent Sessions
            if (studyProvider.goalSessions.isNotEmpty) ...[
              Text(
                'Recent Sessions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              ...studyProvider.goalSessions.take(10).map((session) {
                return Card(
                  child: ListTile(
                    leading: Icon(
                      session.sessionType == StudySessionType.quiz
                          ? Icons.quiz
                          : Icons.style,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      '${session.cardsReviewed} cards reviewed',
                    ),
                    subtitle: Text(
                      '${session.accuracy.toInt()}% accuracy • ${StudyProvider.formatDuration(session.durationSeconds)}',
                    ),
                    trailing: Text(
                      _formatRelativeDate(session.startedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return AppColors.success;
    if (progress >= 0.5) return AppColors.primary;
    if (progress >= 0.25) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _calculateAvgSessionTime(StudyProvider provider) {
    final sessions = provider.goalSessions;
    if (sessions.isEmpty) return '0m';

    final totalSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final avgSeconds = totalSeconds ~/ sessions.length;
    return StudyProvider.formatDuration(avgSeconds);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return _formatDate(date);
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
                  color: valueColor ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
