import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/models.dart';

/// Provides state management for flashcards within a deck.
///
/// This provider manages the list of flashcards for a specific deck
/// and provides CRUD operations with automatic UI updates.
class FlashcardsProvider extends ChangeNotifier {
  final DatabaseHelper _db;

  /// Current deck ID being viewed
  String? _currentDeckId;

  /// List of flashcards for the current deck
  List<Flashcard> _flashcards = [];

  /// Whether flashcards are currently loading
  bool _isLoading = false;

  /// Error message if something went wrong
  String? _error;

  FlashcardsProvider(this._db);

  // ============================================================
  // Getters
  // ============================================================

  /// Current deck ID
  String? get currentDeckId => _currentDeckId;

  /// All flashcards for the current deck
  List<Flashcard> get flashcards => List.unmodifiable(_flashcards);

  /// Flashcards that are due for review
  List<Flashcard> get dueFlashcards =>
      _flashcards.where((c) => c.isDue).toList();

  /// Flashcards that are not yet mastered
  List<Flashcard> get unmasteredFlashcards =>
      _flashcards.where((c) => !c.isMastered).toList();

  /// Flashcards that are mastered
  List<Flashcard> get masteredFlashcards =>
      _flashcards.where((c) => c.isMastered).toList();

  /// Total card count
  int get cardCount => _flashcards.length;

  /// Mastered card count
  int get masteredCount => masteredFlashcards.length;

  /// Whether flashcards are loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  // ============================================================
  // Load Operations
  // ============================================================

  /// Load flashcards for a specific deck
  Future<void> loadFlashcardsForDeck(String deckId) async {
    _currentDeckId = deckId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flashcards = await _db.getFlashcardsForDeck(deckId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load flashcards: $e';
      notifyListeners();
    }
  }

  /// Reload flashcards for the current deck
  Future<void> refresh() async {
    if (_currentDeckId == null) return;
    await loadFlashcardsForDeck(_currentDeckId!);
  }

  // ============================================================
  // CRUD Operations
  // ============================================================

  /// Create a new flashcard
  Future<Flashcard> createFlashcard({
    required String deckId,
    required String front,
    required String back,
    String? notes,
  }) async {
    final card = Flashcard.create(
      deckId: deckId,
      front: front,
      back: back,
      notes: notes,
    );

    await _db.insertFlashcard(card);

    if (deckId == _currentDeckId) {
      _flashcards.add(card);
      notifyListeners();
    }

    return card;
  }

  /// Create multiple flashcards in a batch
  Future<List<Flashcard>> createFlashcards({
    required String deckId,
    required List<Map<String, String>> cardData,
  }) async {
    final cards = cardData.map((data) {
      return Flashcard.create(
        deckId: deckId,
        front: data['front'] ?? '',
        back: data['back'] ?? '',
        notes: data['notes'],
      );
    }).toList();

    await _db.insertFlashcards(cards);

    if (deckId == _currentDeckId) {
      _flashcards.addAll(cards);
      notifyListeners();
    }

    return cards;
  }

  /// Update an existing flashcard
  Future<void> updateFlashcard(Flashcard card) async {
    final updatedCard = card.copyWith(updatedAt: DateTime.now());
    await _db.updateFlashcard(updatedCard);

    final index = _flashcards.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      _flashcards[index] = updatedCard;
      notifyListeners();
    }
  }

  /// Record a review for a flashcard
  ///
  /// [quality] is the user's rating: 0 = Hard, 1 = Medium, 2 = Easy
  Future<void> recordReview(String cardId, int quality) async {
    final index = _flashcards.indexWhere((c) => c.id == cardId);
    if (index < 0) return;

    final card = _flashcards[index];
    final updatedCard = card.recordReview(quality: quality);

    await _db.updateFlashcard(updatedCard);
    _flashcards[index] = updatedCard;
    notifyListeners();
  }

  /// Delete a flashcard
  Future<void> deleteFlashcard(String cardId) async {
    await _db.deleteFlashcard(cardId);

    _flashcards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  /// Get a flashcard by ID
  Flashcard? getFlashcardById(String cardId) {
    return _flashcards.cast<Flashcard?>().firstWhere(
          (c) => c?.id == cardId,
          orElse: () => null,
        );
  }

  /// Clear current state
  void clear() {
    _currentDeckId = null;
    _flashcards = [];
    _error = null;
    notifyListeners();
  }

  /// Get a shuffled list of flashcards for study
  List<Flashcard> getShuffledFlashcards() {
    final shuffled = List<Flashcard>.from(_flashcards);
    shuffled.shuffle();
    return shuffled;
  }

  /// Get flashcards for quiz mode (with distractors)
  List<Flashcard> getFlashcardsForQuiz({int limit = 10}) {
    final available = List<Flashcard>.from(_flashcards);
    available.shuffle();
    return available.take(limit).toList();
  }
}
