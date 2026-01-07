import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/ui/widgets/empty_state_widget.dart';
import 'package:skill_forge/ui/theme/app_theme.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('Displays custom empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.folder_open,
              title: 'No Items',
              description: 'Add your first item',
              actionText: 'Add Item',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text('No Items'), findsOneWidget);
      expect(find.text('Add your first item'), findsOneWidget);
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('Uses noGoals preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noGoals(onCreate: () {}),
          ),
        ),
      );

      expect(find.text('Welcome to Skill Forge!'), findsOneWidget);
      expect(find.textContaining('Create your first learning goal'), findsOneWidget);
      expect(find.text('Create Your First Goal'), findsOneWidget);
    });

    testWidgets('Uses noDecks preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noDecks(onGenerate: () {}, onCreate: () {}),
          ),
        ),
      );

      expect(find.text('Goal Created!'), findsOneWidget);
      expect(find.textContaining('no content yet'), findsOneWidget);
      expect(find.text('Generate Content'), findsOneWidget);
      expect(find.text('Create Empty Deck'), findsOneWidget);
    });

    testWidgets('Uses noCards preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noCards(onAdd: () {}),
          ),
        ),
      );

      expect(find.text('No Cards Yet'), findsOneWidget);
      expect(find.text('Add Cards'), findsOneWidget);
    });

    testWidgets('Triggers action callback when button pressed', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noGoals(
              onCreate: () => actionTriggered = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create Your First Goal'));
      expect(actionTriggered, true);
    });

    testWidgets('No action button when callback is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.info,
              title: 'Empty',
              description: 'No action',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('Shows two buttons for noDecks preset', (tester) async {
      bool generatePressed = false;
      bool createPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noDecks(
              onGenerate: () => generatePressed = true,
              onCreate: () => createPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Generate Content'));
      expect(generatePressed, true);

      await tester.tap(find.text('Create Empty Deck'));
      expect(createPressed, true);
    });

    testWidgets('Uses allCaughtUp preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.allCaughtUp(onPractice: () {}),
          ),
        ),
      );

      expect(find.text('All Caught Up!'), findsOneWidget);
      expect(find.textContaining('No cards due'), findsOneWidget);
      expect(find.text('Practice More'), findsOneWidget);
    });

    testWidgets('Uses noSearchResults preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStates.noSearchResults(onClear: () {}),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
    });
  });
}

