import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// General helper functions for LifeGuard AI
class Helpers {
  Helpers._();

  /// Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }

  /// Format time
  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Format time from hour and minute
  static String formatTimeFromParts(int hour, int minute) {
    final time = DateTime(2024, 1, 1, hour, minute);
    return DateFormat('hh:mm a').format(time);
  }

  /// Format phone number for display
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    } else if (phone.length == 11 && phone.startsWith('1')) {
      return '+1 (${phone.substring(1, 4)}) ${phone.substring(4, 7)}-${phone.substring(7)}';
    }
    return phone;
  }

  /// Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Capitalize first letter of string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Get age from date of birth
  static int getAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.white),
            const SizedBox(width: AppDimensions.paddingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: AppDimensions.paddingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.white),
            const SizedBox(width: AppDimensions.paddingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.white),
            const SizedBox(width: AppDimensions.paddingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive ? AppColors.error : AppColors.primaryBlue,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Format duration in seconds to readable format
  static String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Generate a random color from a string (for avatars)
  static Color generateColorFromString(String text) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.accentBlue,
      AppColors.success,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
    ];
    final index = text.hashCode.abs() % colors.length;
    return colors[index];
  }
}

