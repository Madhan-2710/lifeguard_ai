import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../router/app_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Clear any stale auth errors from a previous screen.
    context.read<AuthCubit>().resetError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendResetLink() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().forgotPassword(
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isLoading = authState.status == AuthStatus.loading;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success && state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
          context.go(AppRoutes.login);
        } else if (state.status == AuthStatus.failure &&
            state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.forgotPassword)),
        body: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.paddingXL),
                const Text(
                  'Enter your email to receive a password reset link.',
                  style: TextStyle(
                    fontSize: AppDimensions.fontLG,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXXL),
                CustomTextField(
                  controller: _emailController,
                  label: AppStrings.email,
                  hint: 'Enter your registered email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                CustomButton(
                  label: AppStrings.sendResetLink,
                  isLoading: isLoading,
                  onPressed: _handleSendResetLink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}