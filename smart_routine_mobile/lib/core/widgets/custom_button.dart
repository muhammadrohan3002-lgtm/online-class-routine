import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? customColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 48,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = customColor ?? AppColors.primary;

    Widget child;
    if (isLoading) {
      child = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      child = Text(text);
    }

    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;
    switch (variant) {
      case ButtonVariant.primary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: Size(width ?? double.infinity, height),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;

      case ButtonVariant.secondary:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.primary,
            minimumSize: Size(width ?? double.infinity, height),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;

      case ButtonVariant.outline:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            minimumSize: Size(width ?? double.infinity, height),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;

      case ButtonVariant.text:
        button = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: color,
            minimumSize: Size(width ?? 0, height),
          ),
          onPressed: effectiveOnPressed,
          child: child,
        );
        break;
    }

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}
