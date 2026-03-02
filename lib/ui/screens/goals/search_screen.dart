import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';
import 'goal_detail_screen.dart';

/// Screen for searching goals, decks, and cards.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all'; // all, goals, decks, cards

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search goals, decks, cards...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterType == 'all',
                  onSelected: () => setState(() => _filterType = 'all'),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: 'Goals',
                  selected: _filterType == 'goals',
                  onSelected: () => setState(() => _filterType = 'goals'),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: 'Decks',
                  selected: _filterType == 'decks',
                  onSelected: () => setState(() => _filterType = 'decks'),
                ),
                const SizedBox(width: AppSpacing.s),
                _FilterChip(
                  label: 'Cards',
                  selected: _filterType == 'cards',
                  onSelected: () => setState(() => _filterType = 'cards'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Search results
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.m),
          Text(
            'Start typing to search',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final goalsProvider = context.watch<GoalsProvider>();
    final query = _searchQuery.toLowerCase();

    final results = <_SearchResult>[];

    // Search goals
    if (_filterType == 'all' || _filterType == 'goals') {
      for (final goal in goalsProvider.goals) {
        if (goal.name.toLowerCase().contains(query) ||
            (goal.description?.toLowerCase().contains(query) ?? false)) {
          results.add(
            _SearchResult(
              type: 'goal',
              title: goal.name,
              subtitle: goal.description ?? 'Learning Goal',
              icon: goal.icon,
              goalId: goal.id,
            ),
          );
        }
      }
    }

    // For decks and cards, we need to search through the database
    // This is simplified - in production you'd use a proper search service

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No results for "$_searchQuery"',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Try a different search term',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultTile(
          result: result,
          onTap: () => _navigateToResult(result),
        );
      },
    );
  }

  void _navigateToResult(_SearchResult result) {
    switch (result.type) {
      case 'goal':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalDetailScreen(goalId: result.goalId!),
          ),
        );
        break;
      case 'deck':
        // Navigate to deck detail
        break;
      case 'card':
        // Navigate to card in deck
        break;
    }
  }
}

class _SearchResult {
  final String type;
  final String title;
  final String subtitle;
  final String? icon;
  final String? goalId;

  _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    this.icon,
    this.goalId,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final _SearchResult result;
  final VoidCallback onTap;

  const _SearchResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: ListTile(
        leading: result.icon != null
            ? Text(result.icon!, style: const TextStyle(fontSize: 24))
            : Icon(_getIconForType(result.type)),
        title: Text(result.title),
        subtitle: Text(result.subtitle),
        trailing: _buildTypeBadge(context),
        onTap: onTap,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'goal':
        return Icons.flag_outlined;
      case 'deck':
        return Icons.layers_outlined;
      case 'card':
        return Icons.style_outlined;
      default:
        return Icons.search;
    }
  }

  Widget _buildTypeBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.smallBorderRadius,
      ),
      child: Text(
        result.type.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}
