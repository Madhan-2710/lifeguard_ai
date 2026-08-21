import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.read<AuthCubit>().checkAuthStatus();
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (_hasNavigated) return;

    switch (state.status) {
      case AuthStatus.authenticated:
        _hasNavigated = true;
        context.go(AppRoutes.dashboard);
      case AuthStatus.unauthenticated:
        _hasNavigated = true;
        if (state.onboardingCompleted) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboarding);
        }
      case AuthStatus.failure:
        // Fall back to the onboarding flow if we cannot verify the session.
        _hasNavigated = true;
        if (state.onboardingCompleted) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboarding);
        }
      case AuthStatus.initial:
      case AuthStatus.loading:
      case AuthStatus.success:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    AppAssets.lifeguardLogo,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              const Text(
                AppStrings.splashTitle,
                style: TextStyle(
                  fontSize: AppDimensions.fontDisplay,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                AppStrings.splashSubtitle,
                style: TextStyle(
                  fontSize: AppDimensions.fontLG,
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
              const SizedBox(height: AppDimensions.paddingXXL * 2),
            ],
          ),
        ),
      ),
    );
  }
}