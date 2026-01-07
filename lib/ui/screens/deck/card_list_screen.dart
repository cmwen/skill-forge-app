import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';
import 'add_card_screen.dart';

/// Screen showing all cards in a deck with search and edit capabilities.
class CardListScreen extends StatefulWidget {
  final String deckId;
  final String goalId;

  const CardListScreen({
    super.key,
    required this.deckId,
    required this.goalId,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  String _searchQuery = '';
  String _filterMode = 'all'; // all, due, mastered, learning
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardsProvider>().loadFlashcardsForDeck(widget.deckId);
    });
  }

  List<Flashcard> _getFilteredCards(FlashcardsProvider provider) {
    var cards = provider.flashcards;

    // Apply filter
    switch (_filterMode) {
      case 'due':
        cards = cards.where((c) => c.isDue).toList();
        break;
      case 'mastered':
        cards = cards.where((c) => c.isMastered).toList();
        break;
      case 'learning':
        cards = cards.where((c) => !c.isMastered).toList();
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      cards = cards.where((c) {
        return c.front.toLowerCase().contains(query) ||
            c.back.toLowerCase().contains(query) ||
            (c.notes?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return cards;
  }

  void _showCardOptions(Flashcard card) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Card'),
              onTap: () {
                Navigator.pop(context);
                _editCard(card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Progress'),
              onTap: () {
                Navigator.pop(context);
                _resetCardProgress(card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Card',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteCard(card);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editCard(Flashcard card) {
    final frontController = TextEditingController(text: card.front);
    final backController = TextEditingController(text: card.back);
    final notesController = TextEditingController(text: card.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Front'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: frontController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Text('Back'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: backController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              const Text('Notes (optional)'),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final updatedCard = card.copyWith(
                front: frontController.text.trim(),
                back: backController.text.trim(),
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
              await context.read<FlashcardsProvider>().updateFlashcard(updatedCard);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetCardProgress(Flashcard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will reset the card\'s review schedule and mastery status. You\'ll need to relearn this card.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final resetCard = card.copyWith(
                reviewCount: 0,
                correctCount: 0,
                easeFactor: 2.5,
                intervalDays: 1.0,
                nextReviewAt: DateTime.now(),
              );
              await context.read<FlashcardsProvider>().updateFlashcard(resetCard);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCard(Flashcard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card?'),
        content: const Text(
          'This will permanently delete this card. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<FlashcardsProvider>().deleteFlashcard(card.id);
              await context.read<DecksProvider>().refreshDeckStats(widget.deckId);
              await context.read<GoalsProvider>().refreshGoalStats(widget.goalId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decksProvider = context.watch<DecksProvider>();
    final flashcardsProvider = context.watch<FlashcardsProvider>();
    final deck = decksProvider.getDeckById(widget.deckId);

    if (deck == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Deck not found')),
      );
    }

    final filteredCards = _getFilteredCards(flashcardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search cards...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text('${deck.name} Cards'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filterMode = value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    if (_filterMode == 'all')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('All Cards'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'due',
                child: Row(
                  children: [
                    if (_filterMode == 'due')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Due for Review'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'learning',
                child: Row(
                  children: [
                    if (_filterMode == 'learning')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Learning'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mastered',
                child: Row(
                  children: [
                    if (_filterMode == 'mastered')
                      const Icon(Icons.check, size: 18)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    const Text('Mastered'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: flashcardsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.layers_outlined,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No cards match your search'
                            : 'No cards in this deck',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_searchQuery.isEmpty) ...[
                        const SizedBox(height: AppSpacing.m),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddCardScreen(deckId: widget.deckId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Card'),
                        ),
                      ],
                    ],
                  ),
                )
              : ListView.builder(
                  padding: AppSpacing.screenPadding,
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return _CardListItem(
                      card: card,
                      onTap: () => _editCard(card),
                      onLongPress: () => _showCardOptions(card),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddCardScreen(deckId: widget.deckId),
            ),
          );
          if (result == true) {
            await flashcardsProvider.loadFlashcardsForDeck(widget.deckId);
            await context.read<DecksProvider>().refreshDeckStats(widget.deckId);
            await context.read<GoalsProvider>().refreshGoalStats(widget.goalId);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  final Flashcard card;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CardListItem({
    required this.card,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.mediumBorderRadius,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      card.front,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                card.back,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (card.notes != null && card.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Notes: ${card.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text(
                    'Reviews: ${card.reviewCount}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    'Accuracy: ${card.accuracy.toInt()}%',
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

  Widget _buildStatusBadge(BuildContext context) {
    if (card.isMastered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: AppRadius.smallBorderRadius,
        ),
        child: const Text(
          'Mastered',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else if (card.isDue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: AppRadius.smallBorderRadius,
        ),
        child: const Text(
          'Due',
          style: TextStyle(
            color: AppColors.warning,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
