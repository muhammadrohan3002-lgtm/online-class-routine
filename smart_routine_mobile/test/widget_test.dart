import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine_mobile/core/widgets/custom_button.dart';
import 'package:smart_routine_mobile/core/widgets/status_badge.dart';
import 'package:smart_routine_mobile/core/widgets/empty_state_view.dart';

void main() {
  group('Core Reusable Widgets Tests', () {
    testWidgets('CustomButton renders text and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Save Schedule',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Save Schedule'), findsOneWidget);

      await tester.tap(find.text('Save Schedule'));
      expect(tapped, isTrue);
    });

    testWidgets('CustomButton shows progress indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Signing In',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing In'), findsNothing);
    });

    testWidgets('StatusBadge displays priority badges correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.priority('high'),
                StatusBadge.priority('low'),
                StatusBadge.attendance('present'),
                StatusBadge.attendance('absent'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('High'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Absent'), findsOneWidget);
    });

    testWidgets('EmptyStateView renders title, subtitle, and action button', (tester) async {
      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.calendar_today_rounded,
              title: 'No Classes Scheduled',
              subtitle: 'Enjoy your free day!',
              buttonText: 'Add Class',
              onButtonPressed: () => buttonClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('No Classes Scheduled'), findsOneWidget);
      expect(find.text('Enjoy your free day!'), findsOneWidget);
      expect(find.text('Add Class'), findsOneWidget);

      await tester.tap(find.text('Add Class'));
      expect(buttonClicked, isTrue);
    });
  });
}
