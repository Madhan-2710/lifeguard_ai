import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Custom text field widget for LifeGuard AI
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: AppDimensions.fontMD,
        color: enabled ? AppColors.textPrimary : AppColors.greyMedium,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        labelStyle: TextStyle(
          color: errorText != null ? AppColors.error : AppColors.textSecondary,
          fontSize: AppDimensions.fontSM,
        ),
        hintStyle: const TextStyle(
          color: AppColors.greyMedium,
          fontSize: AppDimensions.fontMD,
        ),
        helperStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: AppDimensions.fontSM,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: AppDimensions.fontSM,
        ),
        counterStyle: const TextStyle(
          color: AppColors.greyMedium,
          fontSize: AppDimensions.fontXS,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMD,
              vertical: AppDimensions.paddingMD,
            ),
        filled: true,
        fillColor: enabled
            ? (readOnly ? AppColors.greyLight : AppColors.offWhite)
            : AppColors.greyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.greyLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.greyLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(
            color: errorText != null ? AppColors.error : AppColors.primaryBlue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
      ),
    );
  }
}

