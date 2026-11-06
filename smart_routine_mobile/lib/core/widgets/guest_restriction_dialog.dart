import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Checks if current session is guest mode. If so, shows restriction dialog
/// and returns true (meaning restricted/blocked).
bool checkGuestRestricted(
  BuildContext context,
  WidgetRef ref, {
  String action = 'create or modify personal data',
}) {
  final user = ref.read(authProvider).user;
  final isGuest = user == null ||
      user.isGuest ||
      user.email == 'guest@cse.edu' ||
      user.id.contains('guest');

  if (isGuest) {
    showGuestRestrictionDialog(context, action: action);
    return true;
  }
  return false;
}

/// Displays a modern, friendly modal dialog prompting the guest to sign in or register
Future<void> showGuestRestrictionDialog(
  BuildContext context, {
  String action = 'perform this action',
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Badge with gradient
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),

            // Dialog Title
            Text(
              'Guest Mode (View Only)',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            // Dialog Explanation
            Text(
              'Guests can explore sample routines, tasks, and basic features. To $action and securely sync your personal schedule, please sign in or create an account.',
              textAlign: TextAlign.center,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).hintColor,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 24),

            // Action: Create Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.person_add_rounded, size: 20),
                label: const Text(
                  'Create Free Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/register');
                },
              ),
            ),
            const SizedBox(height: 10),

            // Action: Sign In Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(ctx).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: BorderSide(
                    color: Theme.of(ctx).colorScheme.primary.withOpacity(0.5),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text(
                  'Sign In to Existing Account',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/login');
                },
              ),
            ),
            const SizedBox(height: 8),

            // Dismiss: Keep Exploring
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Keep Exploring as Guest',
                style: TextStyle(
                  color: Theme.of(ctx).hintColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
