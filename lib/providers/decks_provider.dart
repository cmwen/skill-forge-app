import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Provides state management for decks within a learning goal.
///
/// This provider manages the list of decks for a specific goal
/// and provides CRUD operations with automatic UI updates.
class DecksProvider extends ChangeNotifier {
  final DatabaseHelper _db;

  /// Current goal ID being viewed
  String? _currentGoalId;

  /// List of decks for the current goal
  List<Deck> _decks = [];

  /// Whether decks are currently loading
  bool _isLoading = false;

  /// Error message if something went wrong
  String? _error;

  /// Statistics for each deck (card count, mastered count)
  final Map<String, DeckStats> _deckStats = {};

  DecksProvider(this._db);

  // ============================================================
  // Getters
  // ============================================================

  /// Current goal ID
  String? get currentGoalId => _currentGoalId;

  /// Decks for the current goal
  List<Deck> get decks => List.unmodifiable(_decks);

  /// Whether decks are loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// Get stats for a specific deck
  DeckStats? getStatsForDeck(String deckId) => _deckStats[deckId];

  // ============================================================
  // Load Operations
  // ============================================================

  /// Load decks for a specific goal
  Future<void> loadDecksForGoal(String goalId) async {
    _currentGoalId = goalId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _decks = await _db.getDecksForGoal(goalId);
      await _loadDeckStats();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load decks: $e';
      notifyListeners();
    }
  }

  /// Load statistics for all decks
  Future<void> _loadDeckStats() async {
    _deckStats.clear();
    for (final deck in _decks) {
      final cardCount = await _db.getCardCountForDeck(deck.id);
      final masteredCount = await _db.getMasteredCardCountForDeck(deck.id);

      _deckStats[deck.id] = DeckStats(
        cardCount: cardCount,
        masteredCount: masteredCount,
      );
    }
  }

  /// Refresh stats for a specific deck
  Future<void> refreshDeckStats(String deckId) async {
    final cardCount = await _db.getCardCountForDeck(deckId);
    final masteredCount = await _db.getMasteredCardCountForDeck(deckId);

    _deckStats[deckId] = DeckStats(
      cardCount: cardCount,
      masteredCount: masteredCount,
    );
    notifyListeners();
  }

  /// Refresh all deck stats
  Future<void> refreshAllDeckStats() async {
    await _loadDeckStats();
    notifyListeners();
  }

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Create a new deck
  Future<Deck> createDeck({
    required String goalId,
    required String name,
    String? description,
    String? source,
  }) async {
    final deck = Deck.create(
      goalId: goalId,
      name: name,
      description: description,
      source: source,
    );

    await _db.insertDeck(deck);

    if (goalId == _currentGoalId) {
      _decks.insert(0, deck);
      _deckStats[deck.id] = const DeckStats(cardCount: 0, masteredCount: 0);
      notifyListeners();
    }

    return deck;
  }

  /// Update an existing deck
  Future<void> updateDeck(Deck deck) async {
    final updatedDeck = deck.copyWith(updatedAt: DateTime.now());
    await _db.updateDeck(updatedDeck);

    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index >= 0) {
      _decks[index] = updatedDeck;
      notifyListeners();
    }
  }

  /// Delete a deck
  Future<void> deleteDeck(String deckId) async {
    await _db.deleteDeck(deckId);

    _decks.removeWhere((d) => d.id == deckId);
    _deckStats.remove(deckId);
    notifyListeners();
  }

  /// Move a deck to a different goal
  Future<void> moveDeckToGoal(String deckId, String newGoalId) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index < 0) return;

    final deck = _decks[index];
    final updatedDeck = deck.copyWith(goalId: newGoalId);

    await _db.updateDeck(updatedDeck);

    // Remove from current list if we're viewing a different goal
    if (_currentGoalId != newGoalId) {
      _decks.removeAt(index);
      _deckStats.remove(deckId);
      notifyListeners();
    }
  }

  /// Update last studied timestamp for a deck
  Future<void> markDeckStudied(String deckId) async {
    final index = _decks.indexWhere((d) => d.id == deckId);
    if (index < 0) return;

    final deck = _decks[index];
    final updatedDeck = deck.copyWith(lastStudiedAt: DateTime.now());

    await _db.updateDeck(updatedDeck);
    _decks[index] = updatedDeck;
    notifyListeners();
  }

  /// Get a deck by ID
  Deck? getDeckById(String deckId) {
    return _decks.cast<Deck?>().firstWhere(
      (d) => d?.id == deckId,
      orElse: () => null,
    );
  }

  /// Clear current state
  void clear() {
    _currentGoalId = null;
    _decks = [];
    _deckStats.clear();
    _error = null;
    notifyListeners();
  }
}

/// Statistics for a deck
class DeckStats {
  final int cardCount;
  final int masteredCount;

  const DeckStats({required this.cardCount, required this.masteredCount});

  /// Progress percentage (0-100)
  double get progressPercent {
    if (cardCount == 0) return 0.0;
    return (masteredCount / cardCount) * 100;
  }
}
