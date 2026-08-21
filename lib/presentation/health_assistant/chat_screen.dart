import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/service_locator.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/health_assistant/domain/entities/chat_message.dart';
import '../../features/health_assistant/presentation/cubit/health_assistant_cubit.dart';
import '../../features/health_assistant/presentation/cubit/health_assistant_state.dart';
import '../router/app_router.dart';

/// AI Health Assistant chat screen (Phase 5A).
///
/// ChatScreen → HealthAssistantCubit → HealthAssistantRepository →
/// HealthAssistantDataSource → LocalHealthAssistantDataSource.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HealthAssistantCubit>(),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<HealthAssistantCubit>().sendMessage(text);
    _controller.clear();
  }

  void _sendQuickAction(String text) {
    context.read<HealthAssistantCubit>().sendMessage(text);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDimensions.animationNormal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.clearChat),
        content: const Text(AppStrings.healthAssistantClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<HealthAssistantCubit>().clearConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.healthAssistant),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.clearChat,
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: BlocConsumer<HealthAssistantCubit, HealthAssistantState>(
        listener: (context, state) {
          if (state.isResponding) _scrollToBottom();
        },
        builder: (context, state) {
          return Column(
            children: [
              const _SafetyDisclaimer(),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  itemCount:
                      state.messages.length + (state.isResponding ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.messages.length) {
                      return const _RespondingIndicator();
                    }
                    return _MessageBubble(message: state.messages[index]);
                  },
                ),
              ),
              if (state.sosRecommended) const _SosRecommendationBanner(),
              if (state.hasError) _ErrorBanner(state: state),
              _QuickActions(onTap: _sendQuickAction),
              _InputBar(controller: _controller, onSend: _send),
            ],
          );
        },
      ),
    );
  }
}
/// Thin banner reminding the user this is guidance, not medical care.
class _SafetyDisclaimer extends StatelessWidget {
  const _SafetyDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.skyBlue,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: AppDimensions.iconSM,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              AppStrings.healthAssistantDisclaimer,
              style: const TextStyle(
                fontSize: AppDimensions.fontSM,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single chat bubble; user messages right (blue), assistant left (grey).
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingSM,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : AppColors.surfaceBlue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppDimensions.radiusLG),
            topRight: const Radius.circular(AppDimensions.radiusLG),
            bottomLeft: Radius.circular(
              isUser ? AppDimensions.radiusLG : AppDimensions.radiusSM,
            ),
            bottomRight: Radius.circular(
              isUser ? AppDimensions.radiusSM : AppDimensions.radiusLG,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? AppColors.white : AppColors.textPrimary,
                fontSize: AppDimensions.fontMD,
                height: 1.4,
              ),
            ),
            if (message.isError) ...[
              const SizedBox(height: AppDimensions.paddingXS),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    AppStrings.healthAssistantSendFailed,
                    style: TextStyle(
                      fontSize: AppDimensions.fontXS,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Typing indicator shown while the assistant is responding.
class _RespondingIndicator extends StatelessWidget {
  const _RespondingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingXS),
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.surfaceBlue,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppDimensions.paddingSM),
            const Text(
              AppStrings.healthAssistantResponding,
              style: TextStyle(fontSize: AppDimensions.fontSM),
            ),
          ],
        ),
      ),
    );
  }
}
/// Prominent banner shown when the assistant recommends emergency SOS.
/// The button only navigates to the existing SOS screen.
class _SosRecommendationBanner extends StatelessWidget {
  const _SosRecommendationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMD,
        AppDimensions.paddingXS,
        AppDimensions.paddingMD,
        AppDimensions.paddingXS,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.emergencyRedLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: AppColors.emergencyRed.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.emergencyRed,
              ),
              const SizedBox(width: AppDimensions.paddingSM),
              Expanded(
                child: Text(
                  AppStrings.emergencyDetected,
                  style: const TextStyle(
                    color: AppColors.emergencyRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          const Text(
            AppStrings.healthAssistantSosPrompt,
            style: TextStyle(fontSize: AppDimensions.fontSM),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          CustomButton(
            label: AppStrings.openEmergencySos,
            icon: Icons.sos,
            variant: ButtonVariant.emergency,
            onPressed: () => context.push(AppRoutes.sos),
          ),
        ],
      ),
    );
  }
}

/// Error banner with a retry action for the last failed message.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.state});

  final HealthAssistantState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMD,
        AppDimensions.paddingXS,
        AppDimensions.paddingMD,
        AppDimensions.paddingXS,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.emergencyRedLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              state.errorMessage ?? AppStrings.somethingWentWrong,
              style: const TextStyle(fontSize: AppDimensions.fontSM),
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<HealthAssistantCubit>().retryLastMessage(),
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
/// Horizontal row of quick-action chips that send a predefined message.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onTap});

  final ValueChanged<String> onTap;

  static const List<(String, IconData)> _actions = [
    ('Fall', Icons.airline_stops),
    ('Bleeding', Icons.water_drop_outlined),
    ('Breathing', Icons.air),
    ('Chest Pain', Icons.favorite_border),
    ('Unconscious', Icons.person_off_outlined),
    ('First Aid', Icons.medical_services_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMD,
          vertical: AppDimensions.paddingXS,
        ),
        itemCount: _actions.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.paddingSM),
        itemBuilder: (context, index) {
          final (label, icon) = _actions[index];
          return ActionChip(
            avatar: Icon(icon, size: 18, color: AppColors.primaryBlue),
            label: Text(label),
            onPressed: () => onTap(label),
          );
        },
      ),
    );
  }
}

/// Message input row with a send button (disabled while responding).
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppStrings.typeMessage,
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusCircular),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMD,
                    vertical: AppDimensions.paddingSM,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSM),
            BlocBuilder<HealthAssistantCubit, HealthAssistantState>(
              builder: (context, state) {
                return IconButton.filled(
                  onPressed: state.isResponding ? null : onSend,
                  icon: const Icon(Icons.send),
                  tooltip: AppStrings.healthAssistantSend,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
