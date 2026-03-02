import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Screen showing the user guide and help documentation.
class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Guide')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: const [
          _GuideSection(
            icon: Icons.start,
            title: 'Getting Started',
            content: '''
Welcome to Skill Forge! Here's how to start your learning journey:

1. **Create a Goal**: Tap the "New Goal" button to define what you want to learn
2. **Add Decks**: Within your goal, create decks to organize your content
3. **Add Cards**: Add flashcards to your decks manually or generate them with AI
4. **Start Learning**: Practice with flashcards or quizzes
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.flag_outlined,
            title: 'Learning Goals',
            content: '''
Goals help you organize your learning into meaningful objectives.

• **Create Goals**: Define what skill or topic you want to master
• **Track Progress**: See your overall mastery percentage
• **Set Target Dates**: Optional deadlines to keep you motivated
• **Archive Goals**: Complete goals can be archived but not deleted
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.layers_outlined,
            title: 'Decks & Cards',
            content: '''
Organize your learning content into decks of flashcards.

• **Decks**: Collections of related flashcards
• **Flashcards**: Question/answer pairs for spaced repetition
• **Notes**: Add extra context to any card
• **Multiple Decks**: Create as many decks as needed per goal
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.auto_awesome,
            title: 'AI Content Generation',
            content: '''
Use AI to generate flashcard content quickly.

**Copy/Paste Workflow** (No setup required):
1. Go to the Generate tab
2. Define your topic and parameters
3. Copy the generated prompt
4. Paste into any AI (ChatGPT, Claude, etc.)
5. Copy the AI's response back
6. Cards are automatically parsed and saved

**Direct Generation** (Optional):
Configure Ollama, OpenAI, or OpenRouter in Settings for direct generation.
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.school,
            title: 'Study Methods',
            content: '''
Two ways to practice your cards:

**Flashcard Mode**:
• Classic flip-and-review style
• Rate your recall: Again, Hard, Good, or Easy
• Spaced repetition schedules reviews optimally

**Quiz Mode**:
• Multiple choice questions
• Tests recognition and recall
• Requires at least 4 cards in a deck
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.repeat,
            title: 'Spaced Repetition',
            content: '''
Skill Forge uses spaced repetition to optimize your learning.

• **New Cards**: Shown more frequently at first
• **Learning Cards**: Reviewed at increasing intervals
• **Mastered Cards**: Reviewed less often (80%+ accuracy)

Rating your recall:
• **Again**: Card resets, shown again soon
• **Hard**: Shorter interval
• **Good**: Normal interval increase
• **Easy**: Longer interval, faster progress
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.cloud_download,
            title: 'Import & Export',
            content: '''
Your data is yours. Export and import anytime.

**Export Options**:
• **JSON**: Complete backup including progress
• **CSV**: Anki/Quizlet compatible (cards only)

**Import Options**:
• **JSON**: Restore full backup
• **CSV**: Import cards from other apps

Tip: Regularly export your data as backup!
''',
          ),
          SizedBox(height: AppSpacing.m),
          _GuideSection(
            icon: Icons.tips_and_updates,
            title: 'Tips for Success',
            content: '''
Make the most of Skill Forge:

• **Study Daily**: Short, consistent sessions beat long cramming
• **Review Due Cards**: Don't skip due reviews
• **Be Honest**: Rate your recall honestly for best scheduling
• **Use Notes**: Add context to help understanding
• **Break It Down**: Create specific decks for focused topics
• **Track Progress**: Celebrate milestones and mastery!
''',
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.s),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              content.trim(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
