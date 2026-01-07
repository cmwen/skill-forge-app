import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../providers/goals_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for editing an existing learning goal.
class EditGoalScreen extends StatefulWidget {
  final String goalId;

  const EditGoalScreen({super.key, required this.goalId});

  @override
  State<EditGoalScreen> createState() => _EditGoalScreenState();
}

class _EditGoalScreenState extends State<EditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '📚';
  DateTime? _targetDate;
  bool _isSaving = false;
  LearningGoal? _goal;

  // Common emoji icons for goals
  static const List<String> _iconOptions = [
    '📚', '🎯', '💻', '🌍', '✈️', '🎵', '🎮', '⚽',
    '🇪🇸', '🇫🇷', '🇩🇪', '🇯🇵', '🇨🇳', '🇰🇷', '🇮🇹', '🇧🇷',
    '🔬', '🧮', '📊', '🎨', '✍️', '🏋️', '🧘', '🍳',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGoal();
    });
  }

  void _loadGoal() {
    final goalsProvider = context.read<GoalsProvider>();
    final goal = goalsProvider.getGoalById(widget.goalId);
    if (goal != null) {
      setState(() {
        _goal = goal;
        _nameController.text = goal.name;
        _descriptionController.text = goal.description ?? '';
        _selectedIcon = goal.icon;
        _targetDate = goal.targetDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTargetDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() {
        _targetDate = date;
      });
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_goal == null) return;

    setState(() => _isSaving = true);

    try {
      final updatedGoal = _goal!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        icon: _selectedIcon,
        targetDate: _targetDate,
      );

      await context.read<GoalsProvider>().updateGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update goal: $e'),
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
    if (_goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Goal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goal'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveGoal,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Goal name
            const Text('Goal Name'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g., Spanish for Travel',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a goal name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.l),

            // Icon picker
            const Text('Icon'),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: _iconOptions.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: AppRadius.smallBorderRadius,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.l),

            // Description (optional)
            const Text('Description (optional)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Why do you want to learn this?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.l),

            // Target date (optional)
            const Text('Target Date (optional)'),
            const SizedBox(height: AppSpacing.s),
            InkWell(
              onTap: _selectTargetDate,
              borderRadius: AppRadius.smallBorderRadius,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: AppRadius.smallBorderRadius,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _targetDate != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Text(
                        _targetDate != null
                            ? '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}'
                            : 'Select a target date',
                        style: TextStyle(
                          color: _targetDate != null
                              ? null
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _targetDate = null),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Save button
            FilledButton(
              onPressed: _isSaving ? null : _saveGoal,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
