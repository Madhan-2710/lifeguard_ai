import 'package:flutter/material.dart';

/// LifeGuard AI Healthcare Theme Colors — Blue & White
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Secondary Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color skyBlue = Color(0xFFE3F2FD);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F9FF);
  static const Color backgroundBlue = Color(0xFFF0F7FF);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyMedium = Color(0xFF9E9E9E);
  static const Color greyDark = Color(0xFF616161);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Emergency
  static const Color emergencyRed = Color(0xFFD32F2F);
  static const Color emergencyRedLight = Color(0xFFFFCDD2);
  static const Color sosRed = Color(0xFFE53935);
  static const Color sosBackground = Color(0xFFFFF5F5);

  // Card & Surface
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceBlue = Color(0xFFE8F0FE);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [emergencyRed, Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [white, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

