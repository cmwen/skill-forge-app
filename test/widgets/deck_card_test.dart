import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/ui/widgets/deck_card.dart';
import 'package:skill_forge/ui/theme/app_theme.dart';

void main() {
  group('DeckCard Widget Tests', () {
    testWidgets('Displays deck information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Spanish Verbs',
              cardCount: 50,
              masteredCount: 25,
              lastStudiedAt: DateTime.now().subtract(const Duration(days: 1)),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Spanish Verbs'), findsOneWidget);
      expect(find.textContaining('50 cards'), findsOneWidget);
      expect(find.textContaining('25 mastered'), findsOneWidget);
    });

    testWidgets('Shows correct progress bar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Test Deck',
              cardCount: 100,
              masteredCount: 75,
              lastStudiedAt: DateTime.now(),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('100 cards'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Handles zero progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'New Deck',
              cardCount: 10,
              masteredCount: 0,
              lastStudiedAt: null,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('10 cards'), findsOneWidget);
      expect(find.textContaining('Never studied'), findsOneWidget);
    });

    testWidgets('Handles 100% progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Completed Deck',
              cardCount: 20,
              masteredCount: 20,
              lastStudiedAt: DateTime.now(),
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('20 cards'), findsOneWidget);
    });

    testWidgets('Tap triggers callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Test',
              cardCount: 10,
              masteredCount: 5,
              lastStudiedAt: DateTime.now(),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DeckCard));
      expect(tapped, true);
    });

    testWidgets('Long press triggers callback', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Test',
              cardCount: 10,
              masteredCount: 5,
              lastStudiedAt: DateTime.now(),
              onTap: () {},
              onLongPress: () => longPressed = true,
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(DeckCard));
      expect(longPressed, true);
    });

    testWidgets('Handles singular card count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Single Card',
              cardCount: 1,
              masteredCount: 0,
              lastStudiedAt: null,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('1 card'), findsOneWidget);
    });
  });
}
