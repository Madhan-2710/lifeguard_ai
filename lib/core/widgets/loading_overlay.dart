import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// A loading overlay widget that shows a semi-transparent overlay with a loader
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;
  final Color? loaderColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              loaderColor ?? AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: AppDimensions.paddingMD),
                          Text(
                            message!,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontMD,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A full-screen loading widget
class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: AppDimensions.fontMD,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

