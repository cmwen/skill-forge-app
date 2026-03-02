import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A statistics card showing a metric with label.
class StatCard extends StatelessWidget {
  /// The statistic value (e.g., "24h 35m", "435", "66%")
  final String value;

  /// The label describing the statistic
  final String label;

  /// Optional icon
  final IconData? icon;

  /// Optional color for the value
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A row of statistics cards.
class StatsRow extends StatelessWidget {
  final List<StatCard> stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map((stat) => Expanded(child: stat))
          .expand((widget) => [widget, const SizedBox(width: AppSpacing.s)])
          .take(stats.length * 2 - 1)
          .toList(),
    );
  }
}

/// A progress summary card for a goal.
class GoalProgressCard extends StatelessWidget {
  /// Goal icon
  final String icon;

  /// Goal name
  final String name;

  /// Progress percentage (0-100)
  final double progressPercent;

  /// Cards mastered / total cards display
  final String cardsProgress;

  /// Total study time display
  final String studyTime;

  /// Called when tapped
  final VoidCallback? onTap;

  const GoalProgressCard({
    super.key,
    required this.icon,
    required this.name,
    required this.progressPercent,
    required this.cardsProgress,
    required this.studyTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumBorderRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressPercent / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation(
                    progressPercent >= 80
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progressPercent.toInt()}% complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    cardsProgress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    studyTime,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
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
