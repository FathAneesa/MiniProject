import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeHelpers {
  // Create gradient background containers
  static Widget gradientBackground({
    required Widget child,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
      ),
      child: child,
    );
  }

  // Create dashboard gradient background
  static Widget dashboardBackground({required Widget child}) {
    return Container(
      decoration: AppDecorations.dashboardGradientDecoration,
      child: child,
    );
  }

  // Create themed card
  static Widget themedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Card(
      color: AppTheme.cardBackground.withAlpha(217),
      elevation: 10,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(24.0),
        child: child,
      ),
    );
  }

  // Create themed button with different styles
  static Widget themedButton({
    required String text,
    required VoidCallback onPressed,
    ButtonStyle? style,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: style ?? AppButtonStyles.primaryButton,
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  // Create dashboard button with consistent styling
  static Widget dashboardButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double? width,
    double? height,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: AppTheme.textOnPrimary,
          textStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  // Show themed snackbar
  static void showThemedSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    Color bgColor = backgroundColor ?? 
        (isError ? AppTheme.errorColor : AppTheme.successColor);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textOnPrimary,
          ),
        ),
        backgroundColor: bgColor,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show themed dialog
  static Future<T?> showThemedDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(ctx).pop(),
              child: Text(cancelText),
            ),
          if (confirmText != null)
            ElevatedButton(
              onPressed: onConfirm ?? () => Navigator.of(ctx).pop(),
              child: Text(confirmText),
            ),
        ],
      ),
    );
  }

  // Create themed text field
  static Widget themedTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  // Create themed circular avatar with wellness icons
  static Widget themedAvatar({
    double size = 120,
    IconData? icon,
    Gradient? gradient,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient ?? AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.9),
        ),
        child: Icon(
          icon ?? Icons.psychology_outlined,
          size: size * 0.4, // Icon size proportional to container
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

// Custom widgets for common UI patterns
class ThemedWidgets {
  // App logo widget with themed styling (replaces image asset)
  static Widget appLogo({double height = 80}) {
    return ThemeHelpers.themedAvatar(
      size: height,
      icon: Icons.psychology_outlined, // Wellness/brain icon
    );
  }

  // App title widget with themed styling
  static Widget appTitle({
    String title = 'WELLNESS AND PERFORMANCE\nRECOMMENDATION SYSTEM',
    TextAlign textAlign = TextAlign.center,
  }) {
    return Text(
      title,
      textAlign: textAlign,
      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Loading indicator with theme colors
  static Widget loadingIndicator({String? message}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  // Empty state widget
  static Widget emptyState({
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary,
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 24),
            action,
          ],
        ],
      ),
    );
  }
}