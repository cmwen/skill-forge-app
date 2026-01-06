import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card widget representing a deck within a learning goal.
///
/// Displays the deck's name, card count, mastery progress,
/// last studied timestamp, and a practice button.
class DeckCard extends StatelessWidget {
  /// The deck's name
  final String name;

  /// Total number of cards in this deck
  final int cardCount;

  /// Number of mastered cards
  final int masteredCount;

  /// When the deck was last studied
  final DateTime? lastStudiedAt;

  /// Called when the card is tapped
  final VoidCallback? onTap;

  /// Called when the practice button is pressed
  final VoidCallback? onPractice;

  /// Called when the card is long pressed
  final VoidCallback? onLongPress;

  const DeckCard({
    super.key,
    required this.name,
    required this.cardCount,
    required this.masteredCount,
    this.lastStudiedAt,
    this.onTap,
    this.onPractice,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = cardCount > 0 ? masteredCount / cardCount : 0.0;

    return Card(
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.mediumBorderRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  const Icon(
                    Icons.style_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
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
              const SizedBox(height: AppSpacing.s),

              // Stats
              Text(
                '$cardCount cards • $masteredCount mastered',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),

              // Last studied
              Text(
                _formatLastStudied(lastStudiedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                    ),
              ),
              const SizedBox(height: AppSpacing.m),

              // Progress bar and practice button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            minHeight: 6,
                            backgroundColor: AppColors.progressBackground,
                            valueColor: AlwaysStoppedAnimation(
                              progressPercent >= 0.8
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  FilledButton.icon(
                    onPressed: onPractice,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Practice'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
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

  String _formatLastStudied(DateTime? date) {
    if (date == null) return 'Never studied';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Last studied: Just now';
    } else if (difference.inHours < 1) {
      return 'Last studied: ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Last studied: ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Last studied: Yesterday';
    } else {
      return 'Last studied: ${difference.inDays} days ago';
    }
  }
}
