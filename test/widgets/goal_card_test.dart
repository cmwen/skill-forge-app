import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/ui/widgets/goal_card.dart';
import 'package:skill_forge/ui/theme/app_theme.dart';

void main() {
  group('GoalCard Widget Tests', () {
    testWidgets('Displays goal information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎯',
              name: 'Learn Flutter',
              deckCount: 5,
              cardCount: 120,
              progressPercent: 0.65,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('🎯'), findsOneWidget);
      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.text('5 decks • 120 cards'), findsOneWidget);
      expect(find.text('65% complete'), findsOneWidget);
    });

    testWidgets('Shows singular deck text when deckCount is 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '📚',
              name: 'Test Goal',
              deckCount: 1,
              cardCount: 10,
              progressPercent: 0.5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 deck • 10 cards'), findsOneWidget);
    });

    testWidgets('Shows singular card text when cardCount is 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎓',
              name: 'Test Goal',
              deckCount: 2,
              cardCount: 1,
              progressPercent: 0.1,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('2 decks • 1 card'), findsOneWidget);
    });

    testWidgets('Handles zero progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🔰',
              name: 'New Goal',
              deckCount: 0,
              cardCount: 0,
              progressPercent: 0.0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0% complete'), findsOneWidget);
      expect(find.text('0 decks • 0 cards'), findsOneWidget);
    });

    testWidgets('Handles 100% progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '✅',
              name: 'Completed Goal',
              deckCount: 3,
              cardCount: 50,
              progressPercent: 1.0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('100% complete'), findsOneWidget);
    });

    testWidgets('Tap callback is triggered', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎯',
              name: 'Test',
              deckCount: 1,
              cardCount: 10,
              progressPercent: 0.5,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GoalCard));
      expect(tapped, true);
    });

    testWidgets('Long press callback is triggered', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎯',
              name: 'Test',
              deckCount: 1,
              cardCount: 10,
              progressPercent: 0.5,
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(GoalCard));
      expect(longPressed, true);
    });

    testWidgets('Card is displayed with proper styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎯',
              name: 'Styled Goal',
              deckCount: 2,
              cardCount: 20,
              progressPercent: 0.75,
              onTap: () {},
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card, isNotNull);
    });
  });
}
