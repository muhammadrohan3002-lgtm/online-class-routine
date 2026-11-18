import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatelessWidget {
  final String? initialEmail;
  final bool isNewlyRegistered;

  const LoginScreen({
    super.key,
    this.initialEmail,
    this.isNewlyRegistered = false,
  });

  @override
  Widget build(BuildContext context) {
    return WelcomeScreen(
      initialEmail: initialEmail,
      isNewlyRegistered: isNewlyRegistered,
    );
  }
}
