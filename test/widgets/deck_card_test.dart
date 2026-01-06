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
              progressPercent: 0.5,
              lastStudied: 'Yesterday',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Spanish Verbs'), findsOneWidget);
      expect(find.text('25/50 cards'), findsOneWidget);
      expect(find.text('Last studied: Yesterday'), findsOneWidget);
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
              progressPercent: 0.75,
              lastStudied: 'Today',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('75/100 cards'), findsOneWidget);
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
              progressPercent: 0.0,
              lastStudied: 'Never',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0/10 cards'), findsOneWidget);
      expect(find.text('Last studied: Never'), findsOneWidget);
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
              progressPercent: 1.0,
              lastStudied: 'Today',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('20/20 cards'), findsOneWidget);
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
              progressPercent: 0.5,
              lastStudied: 'Today',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DeckCard));
      expect(tapped, true);
    });

    testWidgets('Options menu tap triggers callback', (tester) async {
      bool optionsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: DeckCard(
              name: 'Test',
              cardCount: 10,
              masteredCount: 5,
              progressPercent: 0.5,
              lastStudied: 'Today',
              onTap: () {},
              onOptionsPressed: () => optionsTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      expect(optionsTapped, true);
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
              progressPercent: 0.0,
              lastStudied: 'Never',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('0/1 card'), findsOneWidget);
    });
  });
}
