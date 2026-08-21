import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Clear any stale auth errors from a previous screen.
    context.read<AuthCubit>().resetError();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().register(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
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
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),
                  // App Logo
                  Center(
                    child: Image.asset(
                      AppAssets.lifeguardLogo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingLG),
                  const Text(
                    AppStrings.createAccount,
                    style: TextStyle(
                      fontSize: AppDimensions.fontLargeHeading,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),
                  const Text(
                    'Fill in your details to get started',
                    style: TextStyle(
                      fontSize: AppDimensions.fontLG,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXXL),
                  CustomTextField(
                    controller: _nameController,
                    label: AppStrings.fullName,
                    hint: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    validator: Validators.validateFullName,
                  ),
                  const SizedBox(height: AppDimensions.paddingMD),
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
                    controller: _phoneController,
                    label: AppStrings.phoneNumber,
                    hint: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    validator: Validators.validatePhoneNumber,
                  ),
                  const SizedBox(height: AppDimensions.paddingMD),
                  CustomTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    hint: 'Create a password',
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
                  const SizedBox(height: AppDimensions.paddingMD),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    hint: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => setState(
                        () => _obscureConfirmPassword =
                            !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),
                  CustomButton(
                    label: AppStrings.createAccount,
                    isLoading: isLoading,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: AppDimensions.paddingLG),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text(AppStrings.signIn),
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