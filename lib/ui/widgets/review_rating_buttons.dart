import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Rating buttons for spaced repetition review.
///
/// Displays three buttons for Hard, Medium, and Easy ratings.
class ReviewRatingButtons extends StatelessWidget {
  /// Called when a rating is selected (0 = Hard, 1 = Medium, 2 = Easy)
  final void Function(int rating) onRating;

  /// Whether the buttons are enabled
  final bool enabled;

  const ReviewRatingButtons({
    super.key,
    required this.onRating,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RatingButton(
            label: 'Hard',
            subtitle: 'Review soon',
            color: AppColors.error,
            icon: Icons.close,
            onPressed: enabled ? () => onRating(0) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _RatingButton(
            label: 'Medium',
            subtitle: 'Review later',
            color: AppColors.warning,
            icon: Icons.remove,
            onPressed: enabled ? () => onRating(1) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: _RatingButton(
            label: 'Easy',
            subtitle: 'Got it!',
            color: AppColors.success,
            icon: Icons.check,
            onPressed: enabled ? () => onRating(2) : null,
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: AppRadius.mediumBorderRadius,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mediumBorderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.m,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A progress indicator for study sessions.
class StudyProgressIndicator extends StatelessWidget {
  /// Current card index (1-based)
  final int currentCard;

  /// Total number of cards
  final int totalCards;

  /// Number of correct answers so far
  final int correctCount;

  const StudyProgressIndicator({
    super.key,
    required this.currentCard,
    required this.totalCards,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? currentCard / totalCards : 0.0;

    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.progressBackground,
          ),
        ),
        const SizedBox(height: AppSpacing.s),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card $currentCard of $totalCards',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Correct: $correctCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
