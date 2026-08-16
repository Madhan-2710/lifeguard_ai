import 'package:flutter/material.dart';

/// Responsive dimensions and spacing constants for LifeGuard AI
class AppDimensions {
  AppDimensions._();

  // Padding
  static const double paddingXXS = 2.0;
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Margins
  static const double marginSM = 8.0;
  static const double marginMD = 16.0;
  static const double marginLG = 24.0;
  static const double marginXL = 32.0;

  // Border Radius
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;

  // Font Sizes
  static const double fontXS = 10.0;
  static const double fontSM = 12.0;
  static const double fontMD = 14.0;
  static const double fontLG = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontHeading = 24.0;
  static const double fontLargeHeading = 28.0;
  static const double fontDisplay = 32.0;

  // Icon Sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;
  static const double iconSOS = 80.0;

  // Card Sizes
  static const double cardMinHeight = 100.0;
  static const double cardMaxHeight = 200.0;
  static const double cardElevation = 2.0;
  static const double cardElevationLG = 4.0;

  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightLG = 56.0;
  static const double buttonHeightXL = 64.0;
  static const double buttonWidth = double.infinity;

  // SOS Button
  static const double sosButtonSize = 100.0;
  static const double sosButtonIconSize = 48.0;

  // App Bar
  static const double appBarHeight = 56.0;

  // Bottom Navigation
  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 24.0;

  // Image Sizes
  static const double avatarSize = 48.0;
  static const double avatarSizeLG = 64.0;
  static const double avatarSizeXL = 80.0;

  // Divider
  static const double dividerThickness = 1.0;

  // Screen Constraints
  static const double maxMobileWidth = 430.0;
  static const double maxTabletWidth = 768.0;
  static const double maxDesktopWidth = 1200.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Grid
  static const int gridColumns = 2;
  static const double gridSpacing = 12.0;

  /// Get screen width
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  /// Responsive value based on screen width
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }
}

