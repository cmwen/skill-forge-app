import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A card widget representing a learning goal with progress information.
///
/// Displays the goal's icon, name, deck count, card count, progress bar,
/// and last studied timestamp.
class GoalCard extends StatelessWidget {
  /// The goal's display icon (emoji)
  final String icon;

  /// The goal's name
  final String name;

  /// Number of decks in this goal
  final int deckCount;

  /// Total number of cards across all decks
  final int cardCount;

  /// Number of mastered cards
  final int masteredCount;

  /// When the goal was last studied
  final DateTime? lastStudiedAt;

  /// Called when the card is tapped
  final VoidCallback? onTap;

  /// Called when the card is long pressed
  final VoidCallback? onLongPress;

  const GoalCard({
    super.key,
    required this.icon,
    required this.name,
    required this.deckCount,
    required this.cardCount,
    required this.masteredCount,
    this.lastStudiedAt,
    this.onTap,
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
              // Header row with icon and name
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
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

              // Stats row
              Text(
                '$deckCount ${deckCount == 1 ? 'deck' : 'decks'} • $cardCount total cards',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.s),

              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: AppColors.progressBackground,
                        valueColor: AlwaysStoppedAnimation(
                          progressPercent >= 0.8
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    '${(progressPercent * 100).toInt()}% complete',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s),

              // Last studied
              Text(
                _formatLastStudied(lastStudiedAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled),
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
      return 'Last studied: ${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return 'Last studied: ${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Last studied: Yesterday';
    } else if (difference.inDays < 7) {
      return 'Last studied: ${difference.inDays} days ago';
    } else {
      return 'Last studied: ${date.month}/${date.day}/${date.year}';
    }
  }
}
