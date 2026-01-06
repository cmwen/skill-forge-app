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
              message: 'Add your first item',
              actionLabel: 'Add Item',
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
            body: EmptyStateWidget.noGoals(onAction: () {}),
          ),
        ),
      );

      expect(find.text('No Learning Goals Yet'), findsOneWidget);
      expect(find.text('Create your first goal to start organizing your learning journey.'), findsOneWidget);
      expect(find.text('Create Goal'), findsOneWidget);
    });

    testWidgets('Uses noDecks preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget.noDecks(onAction: () {}),
          ),
        ),
      );

      expect(find.text('No Decks Yet'), findsOneWidget);
      expect(find.text('Create a deck to organize your flashcards.'), findsOneWidget);
      expect(find.text('Create Deck'), findsOneWidget);
    });

    testWidgets('Uses noCards preset correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget.noCards(
              onAddManually: () {},
              onGenerate: () {},
            ),
          ),
        ),
      );

      expect(find.text('No Cards Yet'), findsOneWidget);
      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Generate with AI'), findsOneWidget);
    });

    testWidgets('Triggers action callback when button pressed', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget.noGoals(
              onAction: () => actionTriggered = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Create Goal'));
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
              message: 'No action',
            ),
          ),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('Shows two buttons for noCards preset', (tester) async {
      bool addManuallyPressed = false;
      bool generatePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: EmptyStateWidget.noCards(
              onAddManually: () => addManuallyPressed = true,
              onGenerate: () => generatePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add Card'));
      expect(addManuallyPressed, true);

      await tester.tap(find.text('Generate with AI'));
      expect(generatePressed, true);
    });
  });
}
