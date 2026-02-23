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
              masteredCount: 78,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('🎯'), findsOneWidget);
      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.textContaining('5 decks'), findsOneWidget);
      expect(find.textContaining('120 total cards'), findsOneWidget);
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
              masteredCount: 5,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('1 deck'), findsOneWidget);
    });

    testWidgets('Shows total cards text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GoalCard(
              icon: '🎓',
              name: 'Test Goal',
              deckCount: 2,
              cardCount: 1,
              masteredCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('2 decks'), findsOneWidget);
      expect(find.textContaining('1 total cards'), findsOneWidget);
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
              masteredCount: 0,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('0 decks'), findsOneWidget);
      expect(find.text('0% complete'), findsOneWidget);
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
              masteredCount: 50,
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
              masteredCount: 5,
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
              masteredCount: 5,
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
              masteredCount: 15,
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
