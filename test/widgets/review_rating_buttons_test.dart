import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_forge/ui/widgets/review_rating_buttons.dart';
import 'package:skill_forge/ui/theme/app_theme.dart';

void main() {
  group('ReviewRatingButtons Tests', () {
    testWidgets('Displays all three rating buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) {},
            ),
          ),
        ),
      );

      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('Hard button triggers callback with 0', (tester) async {
      int? receivedRating;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) => receivedRating = rating,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();

      expect(receivedRating, 0);
    });

    testWidgets('Medium button triggers callback with 1', (tester) async {
      int? receivedRating;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) => receivedRating = rating,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      expect(receivedRating, 1);
    });

    testWidgets('Easy button triggers callback with 2', (tester) async {
      int? receivedRating;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) => receivedRating = rating,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();

      expect(receivedRating, 2);
    });

    testWidgets('Buttons are arranged horizontally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) {},
            ),
          ),
        ),
      );

      final row = find.byType(Row);
      expect(row, findsOneWidget);
    });

    testWidgets('All buttons are visible and tappable', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: ReviewRatingButtons(
              onRating: (rating) => tapCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Hard'));
      await tester.pumpAndSettle();
      expect(tapCount, 1);

      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();
      expect(tapCount, 2);

      await tester.tap(find.text('Easy'));
      await tester.pumpAndSettle();
      expect(tapCount, 3);
    });
  });
}
