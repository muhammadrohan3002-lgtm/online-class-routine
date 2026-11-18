import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine_mobile/features/auth/presentation/welcome_screen.dart';
import 'package:smart_routine_mobile/features/auth/providers/auth_provider.dart';

class FakeAuthNotifier extends StateNotifier<AuthState> implements AuthNotifier {
  FakeAuthNotifier([super.state = const AuthState()]);

  @override
  void checkAuthStatus() {}

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  Future<bool> login(String email, String password) async => true;

  @override
  Future<bool> loginAsGuest() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? department,
    String? institution,
  }) async => true;

  @override
  Future<bool> updateProfile({
    String? name,
    String? studentId,
    String? department,
    String? institution,
    int? attendanceThreshold,
    String? currentPassword,
    String? newPassword,
  }) async => true;
}

void main() {
  group('WelcomeScreen Redesign Widget Tests', () {
    testWidgets('renders all required elements of the redesigned login screen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Top Section
      expect(find.text('Smart Routine'), findsOneWidget);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);

      // 2. Main Login Card
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // 3. Register Option
      expect(find.textContaining("Don't have an account?"), findsOneWidget);
      expect(find.textContaining('Register'), findsOneWidget);

      // 4. Guest Option & Divider
      expect(find.text('OR'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('validates empty email and password on Login tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Login without filling fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Validation error messages should appear
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('validates invalid email format', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('password field has show/hide visibility toggle icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => FakeAuthNotifier()),
          ],
          child: const MaterialApp(
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially password is obscured and toggle icon is visibility_outlined
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      // Obscure is now false, toggle is visibility_off_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
