import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Screen showing the privacy policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(
            'Privacy Policy',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Last updated: January 2026',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.l),
          const _PolicySection(
            title: 'Our Commitment to Privacy',
            content: '''
Skill Forge is designed with privacy as a core principle. We believe your learning data belongs to you, and we've built our app to reflect that belief.

**The short version**: Your data stays on your device. We don't collect, track, or sell your personal information.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'Data Storage',
            content: '''
**Local Storage Only**
All your learning content, goals, decks, flashcards, and study progress are stored locally on your device. This data never leaves your device unless you explicitly export it.

**No Cloud Sync**
We don't operate cloud servers or sync services. Your data exists only on the device where you created it.

**No Account Required**
You can use Skill Forge without creating an account, providing an email, or any form of registration.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'What We Don\'t Collect',
            content: '''
• Personal information (name, email, phone)
• Usage analytics or tracking
• Device identifiers
• Location data
• Browsing history
• Any content you create
• Study patterns or habits
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'AI Integration (Optional)',
            content: '''
If you choose to configure AI providers (OpenAI, OpenRouter, or Ollama), please note:

**Your API Keys**
Any API keys you enter are stored locally on your device using secure storage. They are never transmitted to us.

**AI Provider Communication**
When generating content, prompts are sent directly from your device to your chosen AI provider. We are not involved in this communication.

**Third-Party Policies**
If you use third-party AI providers, their privacy policies apply to the data you send them. We encourage you to review:
• OpenAI's privacy policy
• OpenRouter's privacy policy
• Ollama's documentation

**Local AI (Ollama)**
Using Ollama keeps all AI processing on your local network, providing maximum privacy.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'Export & Import',
            content: '''
**Your Data, Your Control**
You can export all your data at any time in JSON or CSV format. This exported file is yours to keep, share, or import into other applications.

**No Hidden Data**
The export contains all your learning data. We don't retain any copies or metadata about your exports.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'App Permissions',
            content: '''
Skill Forge may request the following permissions:

**Storage Access**
Required for importing and exporting data files.

**Network Access**
Only used if you configure AI provider integration. Not required for core functionality.

**Text-to-Speech**
Uses your device's built-in TTS engine for reading cards aloud.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'Changes to This Policy',
            content: '''
If we make changes to this privacy policy, we'll update the "Last updated" date and include the updated policy in the next app release.

Significant changes will be highlighted in the app's release notes.
''',
          ),
          const SizedBox(height: AppSpacing.m),
          const _PolicySection(
            title: 'Contact',
            content: '''
If you have questions about this privacy policy or Skill Forge's privacy practices, please open an issue on our GitHub repository or contact the development team.

We're committed to transparency and will respond to privacy-related inquiries promptly.
''',
          ),
          const SizedBox(height: AppSpacing.l),
          Card(
            color: AppColors.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Privacy First: Your learning data never leaves your device.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.s),
        Text(
          content.trim(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}
