import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An interactive flashcard widget with flip animation.
///
/// Displays front and back content with a smooth 3D flip animation
/// when tapped.
class FlashcardWidget extends StatefulWidget {
  /// The front content (question, term, etc.)
  final String front;

  /// The back content (answer, definition, etc.)
  final String back;

  /// Optional notes shown on the back
  final String? notes;

  /// Whether the card is currently showing the front
  final bool showingFront;

  /// Called when the card is tapped to flip
  final VoidCallback? onTap;

  /// Called when the card is long pressed
  final VoidCallback? onLongPress;

  const FlashcardWidget({
    super.key,
    required this.front,
    required this.back,
    this.notes,
    this.showingFront = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showingFront = true;

  @override
  void initState() {
    super.initState();
    _showingFront = widget.showingFront;
    _controller = AnimationController(
      duration: AppDurations.cardFlip,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animation.addListener(() {
      if (_animation.value >= 0.5 && _showingFront != !widget.showingFront) {
        setState(() {
          _showingFront = _animation.value < 0.5;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showingFront != oldWidget.showingFront) {
      if (widget.showingFront) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
    // Reset when card content changes
    if (widget.front != oldWidget.front || widget.back != oldWidget.back) {
      _controller.reset();
      _showingFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final isShowingBack = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isShowingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.14159),
                    child: _buildCardContent(
                      context,
                      content: widget.back,
                      isBack: true,
                      notes: widget.notes,
                    ),
                  )
                : _buildCardContent(
                    context,
                    content: widget.front,
                    isBack: false,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent(
    BuildContext context, {
    required String content,
    required bool isBack,
    String? notes,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: isBack ? AppColors.surface : AppColors.card,
        borderRadius: AppRadius.largeBorderRadius,
        border: Border.all(
          color: isBack ? AppColors.primary : AppColors.border,
          width: isBack ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label
            Text(
              isBack ? 'ANSWER' : 'QUESTION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textDisabled,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Main content
            Text(
              content,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),

            // Notes (only on back)
            if (isBack && notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              const Divider(),
              const SizedBox(height: AppSpacing.s),
              Text(
                notes,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // Tap hint
            const SizedBox(height: AppSpacing.l),
            Text(
              isBack ? 'Tap to see question' : 'Tap to reveal answer',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textDisabled,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
