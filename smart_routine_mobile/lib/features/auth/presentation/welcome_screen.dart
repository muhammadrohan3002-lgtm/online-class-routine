import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/error_banner.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  final bool isNewlyRegistered;

  const WelcomeScreen({
    super.key,
    this.initialEmail,
    this.isNewlyRegistered = false,
  });

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TapGestureRecognizer _registerRecognizer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController = TextEditingController();
    _registerRecognizer = TapGestureRecognizer()
      ..onTap = () => context.push('/register');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleGuestAccess() async {
    final success = await ref.read(authProvider.notifier).loginAsGuest();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_ethernet_rounded,
              size: 20,
              color: theme.hintColor,
            ),
            tooltip: 'Server Connection Settings',
            onPressed: () => context.push('/settings/server'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==========================================
                        // TOP SECTION: Small Logo + App Name
                        // ==========================================
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.22),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Smart Routine',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: -0.2,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // ==========================================
                        // MAIN LOGIN CARD
                        // ==========================================
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : AppColors.cardLight,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Heading: "Welcome Back"
                                Text(
                                  'Welcome Back',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),

                                // Subtitle: "Sign in to continue"
                                Text(
                                  'Sign in to continue',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: theme.hintColor,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Newly Registered Banner
                                if (widget.isNewlyRegistered) ...[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.successContainer.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Account created! Please sign in.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.successText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Error Banner
                                if (authState.errorMessage != null) ...[
                                  ErrorBanner(message: authState.errorMessage!),
                                  const SizedBox(height: 12),
                                ],

                                // Email input field with email icon
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'student@example.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!val.contains('@') || !val.contains('.')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Password input field with show/hide password functionality
                                CustomTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (val.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 2),

                                // Forgot Password? option
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 28),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      foregroundColor: theme.hintColor,
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Full-width primary Login button
                                CustomButton(
                                  text: 'Login',
                                  isLoading: authState.isLoading,
                                  onPressed: _handleLogin,
                                  height: 46,
                                ),
                                const SizedBox(height: 12),

                                // ==========================================
                                // REGISTER OPTION
                                // ==========================================
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: theme.hintColor,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Register',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                          recognizer: _registerRecognizer,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // ==========================================
                                // GUEST OPTION: Divider with "OR" + Button
                                // ==========================================
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.hintColor.withOpacity(0.7),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Outlined button: "Continue as Guest"
                                SizedBox(
                                  height: 40,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                      side: BorderSide(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        width: 1.1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: authState.isLoading ? null : _handleGuestAccess,
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text(
                                            'Continue as Guest',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
