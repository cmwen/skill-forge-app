import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Screen for creating a new deck within a goal.
class CreateDeckScreen extends StatefulWidget {
  final String goalId;

  const CreateDeckScreen({super.key, required this.goalId});

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createDeck() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final deck = await context.read<DecksProvider>().createDeck(
            goalId: widget.goalId,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            source: 'Manual',
          );

      // Refresh goal stats
      await context.read<GoalsProvider>().refreshGoalStats(widget.goalId);

      if (mounted) {
        Navigator.pop(context, deck);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create deck: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Deck'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Deck name
            const Text('Deck Name'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Episode 1-5 Dialogue',
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a deck name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.l),

            // Description
            const Text('Description (optional)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Add a description for this deck',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Create button
            FilledButton(
              onPressed: _isCreating ? null : _createDeck,
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Deck'),
            ),
          ],
        ),
      ),
    );
  }
}
