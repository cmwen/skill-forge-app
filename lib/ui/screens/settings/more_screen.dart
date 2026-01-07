import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/services.dart';
import '../../../ollama_toolkit/ollama_toolkit.dart';
import '../../theme/app_theme.dart';
import '../goals/goals_screen.dart';
import 'user_guide_screen.dart';
import 'privacy_policy_screen.dart';

/// The More screen with settings and data management.
class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final prefsService = context.read<PreferencesService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          // Learning Goals section
          _SectionHeader(title: 'Learning Goals'),
          _SettingsTile(
            icon: Icons.flag_outlined,
            title: 'Manage Goals',
            subtitle: 'Create, edit, or archive goals',
            onTap: () {
              // Navigate to Goals tab
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GoalsScreen(),
                ),
              );
            },
          ),

          // App Settings section
          _SectionHeader(title: 'App Settings'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Dark theme • Display options',
            onTap: () {
              _showAppearanceSettings(context);
            },
          ),
          _SettingsTile(
            icon: Icons.tune_outlined,
            title: 'Learning Preferences',
            subtitle: 'TTS, quiz timer, auto-play',
            onTap: () {
              _showLearningPreferences(context);
            },
          ),
          _SettingsTile(
            icon: Icons.smart_toy_outlined,
            title: 'LLM Provider (Optional)',
            subtitle: 'Configure API integrations',
            onTap: () {
              _showLLMSettings(context);
            },
          ),

          // Data Management section
          _SectionHeader(title: 'Data Management'),
          _SettingsTile(
            icon: Icons.file_download_outlined,
            title: 'Export All Data',
            subtitle: 'Backup your learning content',
            onTap: () {
              _showExportOptions(context);
            },
          ),
          _SettingsTile(
            icon: Icons.file_upload_outlined,
            title: 'Import Data',
            subtitle: 'Restore from backup',
            onTap: () => _showImportOptions(context),
          ),

          // Help & Support section
          _SectionHeader(title: 'Help & Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'User Guide',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UserGuideScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Skill Forge',
            subtitle: 'Version 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showAppearanceSettings(BuildContext context) {
    final prefsService = context.read<PreferencesService>();
    final currentTheme = prefsService.getThemeMode();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: currentTheme,
              onChanged: (value) async {
                await prefsService.setThemeMode(value!);
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              subtitle: const Text('Coming soon'),
              value: 'light',
              groupValue: currentTheme,
              onChanged: null,
            ),
            RadioListTile<String>(
              title: const Text('Follow system'),
              subtitle: const Text('Coming soon'),
              value: 'system',
              groupValue: currentTheme,
              onChanged: null,
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  void _showLearningPreferences(BuildContext context) {
    final prefsService = context.read<PreferencesService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LearningPreferencesSheet(prefsService: prefsService),
    );
  }

  void _showLLMSettings(BuildContext context) {
    final prefsService = context.read<PreferencesService>();
    final currentProvider = prefsService.getLlmProvider();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LLM Provider Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                currentProvider == 'none'
                    ? 'Current: Not configured\nUsing copy/paste workflow'
                    : 'Current: ${currentProvider.toUpperCase()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Optional: Configure API Access',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.s),
              _LLMProviderTile(
                name: 'OpenAI',
                description: 'GPT-4, GPT-3.5',
                onConfigure: () {
                  Navigator.pop(context);
                  _configureLlmProvider(context, 'openai');
                },
              ),
              _LLMProviderTile(
                name: 'OpenRouter',
                description: 'Access multiple models',
                onConfigure: () {
                  Navigator.pop(context);
                  _configureLlmProvider(context, 'openrouter');
                },
              ),
              _LLMProviderTile(
                name: 'Ollama (Local)',
                description: 'Run models on device',
                onConfigure: () {
                  Navigator.pop(context);
                  _configureOllama(context);
                },
              ),
              if (currentProvider != 'none') ...[
                const SizedBox(height: AppSpacing.m),
                OutlinedButton(
                  onPressed: () async {
                    await prefsService.clearLlmSettings();
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  child: const Text('Clear Configuration'),
                ),
              ],
              const SizedBox(height: AppSpacing.m),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mediumBorderRadius,
                ),
                child: Text(
                  'Note: API configuration is completely optional. The copy/paste workflow works with any LLM without setup.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _configureLlmProvider(BuildContext context, String provider) async {
    final prefsService = context.read<PreferencesService>();
    final apiKeyController = TextEditingController();
    final baseUrlController = TextEditingController();
    final modelController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${provider.toUpperCase()}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider != 'ollama') ...[
                const Text('API Key'),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: apiKeyController,
                  decoration: const InputDecoration(
                    hintText: 'Enter API key',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              if (provider == 'ollama') ...[
                const Text('Base URL'),
                const SizedBox(height: AppSpacing.s),
                TextField(
                  controller: baseUrlController,
                  decoration: const InputDecoration(
                    hintText: 'http://localhost:11434',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
              const Text('Model Name (optional)'),
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: modelController,
                decoration: InputDecoration(
                  hintText: provider == 'ollama' ? 'llama2' : 'gpt-4',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await prefsService.setLlmProvider(provider);
        
        if (apiKeyController.text.isNotEmpty) {
          await prefsService.setLlmApiKey(apiKeyController.text);
        }
        if (baseUrlController.text.isNotEmpty) {
          await prefsService.setLlmBaseUrl(baseUrlController.text);
        }
        if (modelController.text.isNotEmpty) {
          await prefsService.setLlmModel(modelController.text);
        }

        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${provider.toUpperCase()} configured')),
            );
          } catch (e) {
            // Context may have been deactivated
          }
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save config: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          } catch (e) {
            // Context may have been deactivated
          }
        }
      }
    }
  }

  Future<void> _configureOllama(BuildContext context) async {
    final prefsService = context.read<PreferencesService>();
    
    // Load saved configuration
    final savedBaseUrl = prefsService.getLlmBaseUrl() ?? 'http://localhost:11434';
    final savedModel = prefsService.getLlmModel();
    
    final baseUrlController = TextEditingController(text: savedBaseUrl);
    String? selectedModel = savedModel;
    List<String> availableModels = [];
    bool isTestingConnection = false;
    bool connectionSuccess = false;
    String? connectionError;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Configure Ollama'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Base URL'),
                  const SizedBox(height: AppSpacing.s),
                  TextField(
                    controller: baseUrlController,
                    decoration: const InputDecoration(
                      hintText: 'http://localhost:11434',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  
                  // Test Connection Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isTestingConnection ? null : () async {
                        setDialogState(() {
                          isTestingConnection = true;
                          connectionSuccess = false;
                          connectionError = null;
                          availableModels = [];
                        });

                        try {
                          // Create a temporary client with the specified baseUrl
                          final testClient = OllamaClient(
                            baseUrl: baseUrlController.text.trim(),
                          );
                          final response = await testClient.listModels();
                          
                          if (response.models.isNotEmpty) {
                            setDialogState(() {
                              connectionSuccess = true;
                              availableModels = response.models
                                  .map((m) => m.name)
                                  .toList();
                              if (availableModels.isNotEmpty) {
                                selectedModel = availableModels.first;
                              }
                            });
                          } else {
                            setDialogState(() {
                              connectionError = 'No models found on server';
                            });
                          }
                        } catch (e) {
                          setDialogState(() {
                            connectionError = e.toString();
                          });
                        } finally {
                          setDialogState(() {
                            isTestingConnection = false;
                          });
                        }
                      },
                      icon: isTestingConnection
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_find),
                      label: Text(isTestingConnection ? 'Testing...' : 'Test Connection'),
                    ),
                  ),
                  
                  // Connection Status
                  if (connectionSuccess) ...[
                    const SizedBox(height: AppSpacing.s),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: AppRadius.smallBorderRadius,
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: Text(
                              'Connected successfully! Found ${availableModels.length} models',
                              style: const TextStyle(color: AppColors.success, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  if (connectionError != null) ...[
                    const SizedBox(height: AppSpacing.s),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: AppRadius.smallBorderRadius,
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.s),
                          Expanded(
                            child: Text(
                              'Connection failed: $connectionError',
                              style: const TextStyle(color: AppColors.error, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Model Dropdown
                  if (availableModels.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.m),
                    const Text('Select Default Model'),
                    const SizedBox(height: AppSpacing.s),
                    DropdownButtonFormField<String>(
                      initialValue: selectedModel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: availableModels.map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(model),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedModel = value;
                        });
                      },
                    ),
                  ],
                  
                  const SizedBox(height: AppSpacing.m),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.smallBorderRadius,
                    ),
                    child: const Text(
                      'Tip: Make sure Ollama is running with \"ollama serve\"',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: connectionSuccess ? () => Navigator.pop(context, true) : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (result == true && mounted) {
      try {
        await prefsService.setLlmProvider('ollama');
        await prefsService.setLlmBaseUrl(baseUrlController.text.trim());
        
        if (selectedModel != null) {
          await prefsService.setLlmModel(selectedModel!);
        }

        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ollama configured successfully')),
            );
          } catch (e) {
            // Context may have been deactivated
          }
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save Ollama config: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          } catch (e) {
            // Context may have been deactivated
          }
        }
      }
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                'Export Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON (Full backup)'),
              subtitle: const Text('Complete data with progress'),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, ExportFormat.json);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV (Anki/Quizlet compatible)'),
              subtitle: const Text('Cards only'),
              onTap: () {
                Navigator.pop(context);
                _exportData(context, ExportFormat.csv);
              },
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, ExportFormat format) async {
    try {
      final exportService = context.read<ExportImportService>();
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        await exportService.exportAndShare(format: format);

        if (context.mounted) {
          Navigator.pop(context); // Close loading
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export complete')),
            );
          } catch (e) {
            // Context may have been deactivated
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Export failed: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          } catch (e) {
            // Context may have been deactivated
          }
        }
      }
    } catch (e) {
      // Error reading service or showing dialog
    }
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Text(
                'Import Data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('JSON (Full restore)'),
              subtitle: const Text('Restore complete backup'),
              onTap: () {
                Navigator.pop(context);
                _importJson(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV (Cards only)'),
              subtitle: const Text('Import flashcards'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV import coming soon')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }

  Future<void> _importJson(BuildContext context) async {
    try {
      final exportService = context.read<ExportImportService>();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      // Show loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      if (context.mounted) {
        final importResult = await exportService.importFromJson(content);

        if (context.mounted) {
          Navigator.pop(context); // Close loading

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                importResult.success ? 'Import Successful' : 'Import Failed',
              ),
              content: Text(importResult.message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        } catch (e) {
          // Context may have been deactivated
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Skill Forge'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: AppSpacing.m),
            Text(
              'Skill Forge is a privacy-first, AI-powered learning companion that helps you master any skill.',
            ),
            SizedBox(height: AppSpacing.m),
            Text(
              '• Your data stays on your device\n'
              '• No account required\n'
              '• Works with any LLM\n'
              '• Export anytime',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.s,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _LLMProviderTile extends StatelessWidget {
  final String name;
  final String description;
  final VoidCallback onConfigure;

  const _LLMProviderTile({
    required this.name,
    required this.description,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: ListTile(
        title: Text(name),
        subtitle: Text(description),
        trailing: TextButton(
          onPressed: onConfigure,
          child: const Text('Configure'),
        ),
      ),
    );
  }
}

class _LearningPreferencesSheet extends StatefulWidget {
  final PreferencesService prefsService;

  const _LearningPreferencesSheet({required this.prefsService});

  @override
  State<_LearningPreferencesSheet> createState() =>
      _LearningPreferencesSheetState();
}

class _LearningPreferencesSheetState extends State<_LearningPreferencesSheet> {
  late bool _ttsEnabled;
  late bool _ttsAutoPlay;
  late bool _quizTimerEnabled;
  late bool _quizShuffle;
  late int _cardsPerSession;

  @override
  void initState() {
    super.initState();
    _ttsEnabled = widget.prefsService.isTtsEnabled();
    _ttsAutoPlay = widget.prefsService.isTtsAutoPlayEnabled();
    _quizTimerEnabled = widget.prefsService.isQuizTimerEnabled();
    _quizShuffle = widget.prefsService.isQuizShuffleEnabled();
    _cardsPerSession = widget.prefsService.getCardsPerSession();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.l),

            // Audio settings
            Text(
              'Audio',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SwitchListTile(
              title: const Text('Text-to-speech'),
              value: _ttsEnabled,
              onChanged: (value) async {
                await widget.prefsService.setTtsEnabled(value);
                setState(() => _ttsEnabled = value);
              },
            ),
            SwitchListTile(
              title: const Text('Auto-play audio'),
              value: _ttsAutoPlay,
              onChanged: (value) async {
                await widget.prefsService.setTtsAutoPlay(value);
                setState(() => _ttsAutoPlay = value);
              },
            ),
            const SizedBox(height: AppSpacing.m),

            // Quiz settings
            Text(
              'Quiz',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SwitchListTile(
              title: const Text('Enable timer'),
              value: _quizTimerEnabled,
              onChanged: (value) async {
                await widget.prefsService.setQuizTimerEnabled(value);
                setState(() => _quizTimerEnabled = value);
              },
            ),
            SwitchListTile(
              title: const Text('Shuffle questions'),
              value: _quizShuffle,
              onChanged: (value) async {
                await widget.prefsService.setQuizShuffle(value);
                setState(() => _quizShuffle = value);
              },
            ),
            const SizedBox(height: AppSpacing.m),

            // Practice settings
            Text(
              'Practice',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ListTile(
              title: const Text('Cards per session'),
              trailing: DropdownButton<int>(
                value: _cardsPerSession,
                items: [10, 20, 50, 100]
                    .map((n) => DropdownMenuItem(
                          value: n,
                          child: Text('$n'),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    await widget.prefsService.setCardsPerSession(value);
                    setState(() => _cardsPerSession = value);
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
            const SizedBox(height: AppSpacing.m),
          ],
        ),
      ),
    );
  }
}
