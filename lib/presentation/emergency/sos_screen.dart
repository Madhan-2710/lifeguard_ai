import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/sos/presentation/cubit/sos_cubit.dart';
import '../../features/sos/presentation/cubit/sos_state.dart';
import '../router/app_router.dart';

/// Core emergency SOS screen (Phase 3A).
///
/// Flow: press SOS → 5s cancellable countdown → GPS location → load emergency
/// contacts via the domain repository → prepare + persist an emergency event.
/// Actual SMS / network delivery is Phase 3B.
class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SosCubit>(),
      child: const _SosView(),
    );
  }
}

class _SosView extends StatelessWidget {
  const _SosView();

  void _handleState(BuildContext context, SosState state) {
    if (state.status == SosStatus.ready) {
      Helpers.showSuccessSnackBar(context, AppStrings.sosEventPrepared);
    } else if (state.status == SosStatus.noContacts) {
      Helpers.showWarningSnackBar(context, AppStrings.sosNoContactsMessage);
    } else if (state.status == SosStatus.failed) {
      Helpers.showErrorSnackBar(
        context,
        state.message ?? AppStrings.somethingWentWrong,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sosTitle)),
      body: BlocConsumer<SosCubit, SosState>(
        listener: _handleState,
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(status: state.status),
                const SizedBox(height: AppDimensions.paddingLG),
                _SosButton(state: state),
                const SizedBox(height: AppDimensions.paddingLG),
                if (state.status == SosStatus.countdown)
                  _CountdownCard(seconds: state.countdownSeconds),
                if (state.status == SosStatus.ready)
                  _ReadyCard(state: state),
                if (state.status == SosStatus.noContacts)
                  const _NoContactsCard(),
                if (state.status == SosStatus.failed)
                  _FailedCard(state: state),
                const SizedBox(height: AppDimensions.paddingMD),
                _StatusInfoCard(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Opens a Google Maps link in the external maps app.
Future<void> _openMaps(String link) async {
  final uri = Uri.parse(link);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
/// Colored banner showing the current SOS workflow status.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});

  final SosStatus status;

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: info.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(info.icon, color: info.color, size: AppDimensions.iconMD),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              info.label,
              style: TextStyle(
                color: info.color,
                fontSize: AppDimensions.fontLG,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

({String label, Color color, IconData icon}) _statusInfo(SosStatus status) {
  switch (status) {
    case SosStatus.idle:
      return (
        label: AppStrings.sosIdle,
        color: AppColors.primaryBlue,
        icon: Icons.health_and_safety_outlined,
      );
    case SosStatus.countdown:
      return (
        label: AppStrings.sosCountdown,
        color: AppColors.emergencyRed,
        icon: Icons.timer_outlined,
      );
    case SosStatus.locating:
      return (
        label: AppStrings.sosGettingLocation,
        color: AppColors.warning,
        icon: Icons.my_location,
      );
    case SosStatus.loadingContacts:
      return (
        label: AppStrings.sosLoadingContacts,
        color: AppColors.warning,
        icon: Icons.contacts_outlined,
      );
    case SosStatus.preparing:
      return (
        label: AppStrings.sosPreparing,
        color: AppColors.warning,
        icon: Icons.assignment_outlined,
      );
    case SosStatus.ready:
      return (
        label: AppStrings.sosReady,
        color: AppColors.success,
        icon: Icons.check_circle_outline,
      );
    case SosStatus.cancelled:
      return (
        label: AppStrings.sosCancelled,
        color: AppColors.greyDark,
        icon: Icons.cancel_outlined,
      );
    case SosStatus.noContacts:
      return (
        label: AppStrings.sosNoContacts,
        color: AppColors.warning,
        icon: Icons.person_off_outlined,
      );
    case SosStatus.failed:
      return (
        label: AppStrings.sosFailed,
        color: AppColors.error,
        icon: Icons.error_outline,
      );
  }
}

/// Large circular SOS button. Disabled while an SOS is in flight.
class _SosButton extends StatelessWidget {
  const _SosButton({required this.state});

  final SosState state;

  @override
  Widget build(BuildContext context) {
    final active = state.isActive;
    return Center(
      child: GestureDetector(
        onTap: active ? null : () => context.read<SosCubit>().startSos(),
        child: AnimatedContainer(
          duration: AppDimensions.animationNormal,
          width: AppDimensions.sosButtonSize * 1.5,
          height: AppDimensions.sosButtonSize * 1.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.emergencyGradient,
            boxShadow: active
                ? []
                : [
                    BoxShadow(
                      color: AppColors.emergencyRed.withValues(alpha: 0.45),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
          ),
          child: Center(child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (state.status == SosStatus.countdown) {
      return Text(
        '${state.countdownSeconds}',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: AppDimensions.fontDisplay,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    if (state.status == SosStatus.locating ||
        state.status == SosStatus.loadingContacts ||
        state.status == SosStatus.preparing) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      );
    }
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.sos, size: AppDimensions.iconXXL, color: AppColors.white),
        SizedBox(height: AppDimensions.paddingXS),
        Text(
          'SOS',
          style: TextStyle(
            color: AppColors.white,
            fontSize: AppDimensions.fontHeading,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
/// Visible countdown with a Cancel button.
class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            Text(
              AppStrings.sosCountdown,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            AnimatedSwitcher(
              duration: AppDimensions.animationFast,
              child: Text(
                '$seconds',
                key: ValueKey(seconds),
                style: const TextStyle(
                  fontSize: AppDimensions.fontDisplay,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emergencyRed,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            CustomButton(
              label: AppStrings.cancelSOS,
              icon: Icons.close,
              variant: ButtonVariant.emergency,
              onPressed: () => context.read<SosCubit>().cancelSos(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the emergency event has been prepared (Phase 3A end state).
class _ReadyCard extends StatelessWidget {
  const _ReadyCard({required this.state});

  final SosState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: AppDimensions.paddingSM),
                Expanded(
                  child: Text(
                    AppStrings.sosEventPrepared,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (state.locationLink != null) ...[
              const SizedBox(height: AppDimensions.paddingMD),
              CustomButton(
                label: AppStrings.sosOpenLocation,
                icon: Icons.map_outlined,
                variant: ButtonVariant.secondary,
                onPressed: () => _openMaps(state.locationLink!),
              ),
            ],
            if (state.timestamp != null) ...[
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '${AppStrings.sosLocationStatus}: '
                '${Helpers.formatDateTime(state.timestamp!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when the user has no emergency contacts — workflow is stopped.
class _NoContactsCard extends StatelessWidget {
  const _NoContactsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: AppDimensions.iconXL,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              AppStrings.sosNoContactsMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            CustomButton(
              label: AppStrings.sosAddContacts,
              icon: Icons.contacts,
              onPressed: () => context.push(AppRoutes.contacts),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the SOS workflow failed (location, contacts, or persistence).
class _FailedCard extends StatelessWidget {
  const _FailedCard({required this.state});

  final SosState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              state.message ?? AppStrings.somethingWentWrong,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            if (state.permissionDenied) ...[
              CustomButton(
                label: AppStrings.openSettings,
                icon: Icons.settings,
                variant: ButtonVariant.secondary,
                onPressed: () => openAppSettings(),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
            ],
            CustomButton(
              label: AppStrings.sosTryAgain,
              icon: Icons.refresh,
              onPressed: () => context.read<SosCubit>().startSos(),
            ),
          ],
        ),
      ),
    );
  }
}
/// Always-visible summary of location status and contact availability.
class _StatusInfoCard extends StatelessWidget {
  const _StatusInfoCard({required this.state});

  final SosState state;

  @override
  Widget build(BuildContext context) {
    final hasLocation = state.latitude != null && state.longitude != null;
    final locationValue = hasLocation
        ? '${state.latitude!.toStringAsFixed(5)}, '
            '${state.longitude!.toStringAsFixed(5)}'
        : AppStrings.sosLocationNotRequested;
    final contactValue = state.contactCount > 0
        ? '${state.contactCount} contact(s)'
        : 'None';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.my_location,
              label: AppStrings.sosLocationStatus,
              value: locationValue,
            ),
            const Divider(),
            _InfoRow(
              icon: Icons.contacts_outlined,
              label: AppStrings.sosContactAvailability,
              value: contactValue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small icon + label + value row used inside the status info card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSM, color: AppColors.primaryBlue),
        const SizedBox(width: AppDimensions.paddingSM),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: AppDimensions.fontSM,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
