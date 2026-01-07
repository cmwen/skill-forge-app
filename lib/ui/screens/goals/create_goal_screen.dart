import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/goals_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../theme/app_theme.dart';

/// Screen for creating a new learning goal.
class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedIcon = '📚';
  DateTime? _targetDate;
  bool _isCreating = false;

  // Common emoji icons for goals
  static const List<String> _iconOptions = [
    '📚', '🎯', '💻', '🌍', '✈️', '🎵', '🎮', '⚽',
    '🇪🇸', '🇫🇷', '🇩🇪', '🇯🇵', '🇨🇳', '🇰🇷', '🇮🇹', '🇧🇷',
    '🔬', '🧮', '📊', '🎨', '✍️', '🏋️', '🧘', '🍳',
  ];

  // Goal templates
  static const List<Map<String, String>> _templates = [
    {'name': 'Language Learning', 'icon': '🌍', 'description': 'Learn a new language'},
    {'name': 'Programming', 'icon': '💻', 'description': 'Master coding skills'},
    {'name': 'Academic', 'icon': '📚', 'description': 'Study for school or exams'},
    {'name': 'Hobby', 'icon': '🎨', 'description': 'Learn a new hobby'},
    {'name': 'Professional', 'icon': '💼', 'description': 'Career development skills'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectTemplate(Map<String, String> template) {
    setState(() {
      _nameController.text = template['name'] ?? '';
      _descriptionController.text = template['description'] ?? '';
      _selectedIcon = template['icon'] ?? '📚';
    });
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

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final goal = await context.read<GoalsProvider>().createGoal(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            icon: _selectedIcon,
            targetDate: _targetDate,
          );

      if (mounted) {
        // Show success and offer next actions
        _showGoalCreatedDialog(goal.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create goal: $e'),
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

  void _showGoalCreatedDialog(String goalId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: AppSpacing.s),
            Text('Goal Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_selectedIcon ${_nameController.text}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            const Text(
              'Your goal is ready. Now let\'s add some learning content.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to goals list
            },
            child: const Text('Do This Later'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
              // Navigate to Generate screen with goal pre-selected
              context.read<NavigationProvider>().navigateToGenerate();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Content'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Learning Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Goal name
            const Text('What do you want to learn?'),
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
            const Text('Icon (optional)'),
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
                      color:
                          isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: AppRadius.smallBorderRadius,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.l),

            // Description
            const Text('Description (optional)'),
            const SizedBox(height: AppSpacing.s),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'e.g., Learn conversational Spanish for my trip',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.l),

            // Target date
            const Text('Target Completion (optional)'),
            const SizedBox(height: AppSpacing.s),
            InkWell(
              onTap: _selectTargetDate,
              borderRadius: AppRadius.mediumBorderRadius,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mediumBorderRadius,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: AppSpacing.m),
                    Text(
                      _targetDate != null
                          ? '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}'
                          : 'No target date',
                      style: TextStyle(
                        color: _targetDate != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_targetDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _targetDate = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // Templates
            const Text('Common Goal Templates'),
            const SizedBox(height: AppSpacing.s),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: _templates.map((template) {
                return ActionChip(
                  avatar: Text(template['icon']!),
                  label: Text(template['name']!),
                  onPressed: () => _selectTemplate(template),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Create button
            FilledButton(
              onPressed: _isCreating ? null : _createGoal,
              child: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Goal'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
