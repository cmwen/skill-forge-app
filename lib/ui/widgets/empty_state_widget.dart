import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An empty state widget for when there's no content to display.
///
/// Shows an icon, title, description, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  /// Icon to display (optional, defaults to a generic icon)
  final IconData? icon;

  /// Emoji to display instead of icon
  final String? emoji;

  /// Title text
  final String title;

  /// Description text
  final String description;

  /// Action button text (optional)
  final String? actionText;

  /// Called when the action button is pressed
  final VoidCallback? onAction;

  /// Secondary action button text (optional)
  final String? secondaryActionText;

  /// Called when the secondary action button is pressed
  final VoidCallback? onSecondaryAction;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or emoji
            if (emoji != null)
              Text(emoji!, style: const TextStyle(fontSize: 64))
            else
              Icon(
                icon ?? Icons.folder_open_outlined,
                size: 64,
                color: AppColors.textDisabled,
              ),
            const SizedBox(height: AppSpacing.l),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),

            // Description
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.l),

            // Action button
            if (actionText != null && onAction != null)
              ElevatedButton(onPressed: onAction, child: Text(actionText!)),

            // Secondary action
            if (secondaryActionText != null && onSecondaryAction != null) ...[
              const SizedBox(height: AppSpacing.s),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Common empty state presets
class EmptyStates {
  EmptyStates._();

  /// Empty state for no goals
  static Widget noGoals({VoidCallback? onCreate}) {
    return EmptyStateWidget(
      emoji: '📚',
      title: 'Welcome to Skill Forge!',
      description:
          'Create your first learning goal to organize your study materials.',
      actionText: 'Create Your First Goal',
      onAction: onCreate,
    );
  }

  /// Empty state for no decks in a goal
  static Widget noDecks({VoidCallback? onGenerate, VoidCallback? onCreate}) {
    return EmptyStateWidget(
      emoji: '🎯',
      title: 'Goal Created!',
      description:
          'Your goal has no content yet. Generate some learning materials to get started.',
      actionText: 'Generate Content',
      onAction: onGenerate,
      secondaryActionText: 'Create Empty Deck',
      onSecondaryAction: onCreate,
    );
  }

  /// Empty state for no cards in a deck
  static Widget noCards({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.style_outlined,
      title: 'No Cards Yet',
      description: 'Add flashcards to this deck to start learning.',
      actionText: 'Add Cards',
      onAction: onAdd,
    );
  }

  /// Empty state for all caught up
  static Widget allCaughtUp({VoidCallback? onPractice}) {
    return EmptyStateWidget(
      icon: Icons.check_circle_outline,
      title: 'All Caught Up!',
      description: 'No cards due right now. Great work! Check back tomorrow.',
      actionText: 'Practice More',
      onAction: onPractice,
    );
  }

  /// Empty state for no search results
  static Widget noSearchResults({VoidCallback? onClear}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      description: 'Try a different search term.',
      actionText: 'Clear Search',
      onAction: onClear,
    );
  }
}
