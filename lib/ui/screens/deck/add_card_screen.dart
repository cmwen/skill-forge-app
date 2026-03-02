import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/flashcards_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for adding a single flashcard to a deck.
class AddCardScreen extends StatefulWidget {
  final String deckId;

  const AddCardScreen({super.key, required this.deckId});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  bool _addAnother = true;

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await context.read<FlashcardsProvider>().createFlashcard(
        deckId: widget.deckId,
        front: _frontController.text.trim(),
        back: _backController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        if (_addAnother) {
          // Clear form and stay on screen
          _frontController.clear();
          _backController.clear();
          _notesController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card added!'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          // Go back
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Front (question)
            const Text('Front (Question/Term)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _frontController,
              decoration: const InputDecoration(
                hintText: 'e.g., What is the capital of Spain?',
              ),
              maxLines: 3,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the front content';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.l),

            // Back (answer)
            const Text('Back (Answer/Definition)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _backController,
              decoration: const InputDecoration(hintText: 'e.g., Madrid'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the back content';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.l),

            // Notes (optional)
            const Text('Notes (optional)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Add extra context or examples',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.l),

            // Add another toggle
            Row(
              children: [
                Checkbox(
                  value: _addAnother,
                  onChanged: (value) =>
                      setState(() => _addAnother = value ?? true),
                ),
                const Text('Add another card after saving'),
              ],
            ),
            const SizedBox(height: AppSpacing.l),

            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _saveCard,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_addAnother ? 'Add Card' : 'Add Card & Done'),
            ),
          ],
        ),
      ),
    );
  }
}
