import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Custom button widget with multiple variants for LifeGuard AI
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? customChild;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.customChild,
  });

  bool get _isDisabled => isDisabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? _getHeight(),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton();
      case ButtonVariant.secondary:
        return _buildOutlinedButton();
      case ButtonVariant.text:
        return _buildTextButton();
      case ButtonVariant.emergency:
        return _buildEmergencyButton();
      case ButtonVariant.gradient:
        return _buildGradientButton();
    }
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.greyLight,
        disabledForegroundColor: AppColors.greyMedium,
        elevation: _isDisabled ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryBlue,
        disabledForegroundColor: AppColors.greyMedium,
        side: BorderSide(
          color: borderColor ?? (_isDisabled ? AppColors.greyLight : AppColors.primaryBlue),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: _isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryBlue,
        disabledForegroundColor: AppColors.greyMedium,
        padding: EdgeInsets.zero,
        minimumSize: Size(width ?? 0, height ?? _getHeight()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildEmergencyButton() {
    return ElevatedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.emergencyRed,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.greyLight,
        disabledForegroundColor: AppColors.greyMedium,
        elevation: _isDisabled ? 0 : 4,
        shadowColor: AppColors.emergencyRed.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildGradientButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.emergencyGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: _isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.emergencyRed.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Center(
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }

    if (customChild != null) {
      return customChild!;
    }

    if (icon == null) {
      return Text(
        label,
        style: TextStyle(
          fontSize: _getFontSize(),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconPosition == IconPosition.left) ...[
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: AppDimensions.paddingSM),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (iconPosition == IconPosition.right) ...[
          const SizedBox(width: AppDimensions.paddingSM),
          Icon(icon, size: _getIconSize()),
        ],
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.sm:
        return 36.0;
      case ButtonSize.md:
        return 48.0;
      case ButtonSize.lg:
        return 56.0;
      case ButtonSize.xl:
        return 64.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.sm:
        return 12.0;
      case ButtonSize.md:
        return 14.0;
      case ButtonSize.lg:
        return 16.0;
      case ButtonSize.xl:
        return 18.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.sm:
        return 16.0;
      case ButtonSize.md:
        return 18.0;
      case ButtonSize.lg:
        return 20.0;
      case ButtonSize.xl:
        return 24.0;
    }
  }
}

enum ButtonVariant {
  primary,
  secondary,
  text,
  emergency,
  gradient,
}

enum ButtonSize {
  sm,
  md,
  lg,
  xl,
}

enum IconPosition {
  left,
  right,
}

