import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Material Design 3 Theme Configuration for LifeGuard AI
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.white,
        secondary: AppColors.accentBlue,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundBlue,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        color: AppColors.cardBackground,
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(AppDimensions.buttonWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          minimumSize: const Size(AppDimensions.buttonWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontLG,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(
            fontSize: AppDimensions.fontMD,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.offWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.greyMedium),
        prefixIconColor: AppColors.greyMedium,
        suffixIconColor: AppColors.greyMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.greyMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: AppDimensions.fontSM,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppDimensions.fontSM,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.dividerThickness,
        space: AppDimensions.paddingMD,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
        ),
        backgroundColor: AppColors.skyBlue,
        selectedColor: AppColors.primaryBlue,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSM,
          vertical: AppDimensions.paddingXXS,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }
          return AppColors.greyMedium;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.lightBlue;
          }
          return AppColors.greyLight;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryBlue;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        elevation: 8,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: AppDimensions.fontMD,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryBlue,
        linearTrackColor: AppColors.lightBlue,
        circularTrackColor: AppColors.lightBlue,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.fontDisplay,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppDimensions.fontLargeHeading,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: AppDimensions.fontHeading,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppDimensions.fontXXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppDimensions.fontXL,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: AppDimensions.fontLG,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppDimensions.fontMD,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.fontLG,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.fontMD,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.fontSM,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.fontMD,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: AppDimensions.fontSM,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: AppDimensions.fontXS,
          fontWeight: FontWeight.w400,
          color: AppColors.greyMedium,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
        primary: AppColors.lightBlue,
        onPrimary: AppColors.primaryDark,
        secondary: AppColors.accentBlue,
        onSecondary: AppColors.white,
        surface: const Color(0xFF1A1A2E),
        onSurface: AppColors.white,
        error: AppColors.error,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        color: const Color(0xFF1A1A2E),
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
      ),
      // Dark theme continues with similar overrides...
      // For brevity, the light theme is the primary focus
    );
  }
}

