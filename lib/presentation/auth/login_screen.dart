import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any stale auth errors from a previous screen.
    context.read<AuthCubit>().resetError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isLoading = authState.status == AuthStatus.loading;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          context.go(AppRoutes.dashboard);
        } else if (state.status == AuthStatus.failure &&
            state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimensions.paddingXL),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.onboarding),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  const Text(
                    AppStrings.signIn,
                    style: TextStyle(
                      fontSize: AppDimensions.fontLargeHeading,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),
                  const Text(
                    'Welcome back! Sign in to continue',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLG,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  CustomTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: AppDimensions.paddingMD),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go(AppRoutes.forgotPassword),
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMD),
                  CustomButton(
                    label: AppStrings.signIn,
                    isLoading: isLoading,
                    onPressed: _handleLogin,
                  ),
                  const SizedBox(height: AppDimensions.paddingLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.dontHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text(AppStrings.signUp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}