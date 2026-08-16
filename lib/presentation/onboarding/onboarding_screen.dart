import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.health_and_safety,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      color: AppColors.primaryBlue,
    ),
    _OnboardingPage(
      icon: Icons.warning_amber_rounded,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      color: AppColors.emergencyRed,
    ),
    _OnboardingPage(
      icon: Icons.sensors,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      color: AppColors.accentBlue,
    ),
    _OnboardingPage(
      icon: Icons.medication,
      title: AppStrings.onboardingTitle4,
      description: AppStrings.onboardingDesc4,
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await context.read<AuthCubit>().completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _completeOnboarding(),
                    child: const Text(AppStrings.skip),
                  ),
                ],
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            page.icon,
                            size: 60,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXL),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontHeading,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMD),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: AppDimensions.fontLG,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryBlue
                        : AppColors.greyLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            // Get Started / Next button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              child: CustomButton(
                label: _currentPage == _pages.length - 1
                    ? AppStrings.getStarted
                    : AppStrings.next,
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
