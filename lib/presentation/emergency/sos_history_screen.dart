import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/sos/domain/entities/emergency_alert_delivery.dart';
import '../../features/sos/domain/entities/emergency_event.dart';
import '../../features/sos/presentation/cubit/sos_history_cubit.dart';
import '../../features/sos/presentation/cubit/sos_history_state.dart';

/// SOS History screen (Phase 4A).
///
/// Reads previous events from `users/{uid}/sos_alerts` via
/// [EmergencyEventRepository] and displays them newest-first. Reuses
/// [EmergencyEvent] for every history item.
class SosHistoryScreen extends StatelessWidget {
  const SosHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SosHistoryCubit>()..loadHistory(),
      child: const SosHistoryView(),
    );
  }
}

/// Public view so widget tests can pump it with a controlled cubit.
class SosHistoryView extends StatelessWidget {
  const SosHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sosHistoryTitle)),
      body: BlocBuilder<SosHistoryCubit, SosHistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case SosHistoryStatus.initial:
            case SosHistoryStatus.loading:
              return const _LoadingView();
            case SosHistoryStatus.empty:
              return const _EmptyView();
            case SosHistoryStatus.failure:
              return _FailureView(message: state.message);
            case SosHistoryStatus.loaded:
              return _HistoryList(events: state.events);
          }
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppDimensions.paddingMD),
          Text(AppStrings.loading),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.history_toggle_off,
              size: AppDimensions.iconXXL,
              color: AppColors.greyMedium,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              AppStrings.sosHistoryEmpty,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            Text(
              AppStrings.sosHistoryEmptyDescription,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: AppDimensions.iconXL,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              message ?? AppStrings.somethingWentWrong,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            CustomButton(
              label: AppStrings.sosHistoryRetry,
              icon: Icons.refresh,
              variant: ButtonVariant.secondary,
              onPressed: () => context.read<SosHistoryCubit>().loadHistory(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.events});

  final List<EmergencyEvent> events;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: events.length,
      separatorBuilder: (_, _) => const SizedBox(
        height: AppDimensions.paddingMD,
      ),
      itemBuilder: (context, index) => _HistoryCard(event: events[index]),
    );
  }
}
/// A single history item: date/time, event status, delivery status,
/// successful/failed contact counts, and location availability.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    final eventInfo = _eventStatusInfo(event.status);
    final deliveryInfo = _deliveryStatusInfo(event.deliveryStatus);
    final hasLocation =
        (event.latitude != null && event.longitude != null) ||
        (event.locationLink != null && event.locationLink!.isNotEmpty);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date/time header.
            Row(
              children: [
                const Icon(
                  Icons.sos,
                  size: AppDimensions.iconSM,
                  color: AppColors.emergencyRed,
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Expanded(
                  child: Text(
                    event.timestamp != null
                        ? Helpers.formatDateTime(event.timestamp!)
                        : AppStrings.sosHistoryTimeUnavailable,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimensions.paddingLG),
            _InfoRow(
              icon: eventInfo.icon,
              color: eventInfo.color,
              label: AppStrings.sosHistoryEventStatus,
              value: eventInfo.label,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            _InfoRow(
              icon: deliveryInfo.icon,
              color: deliveryInfo.color,
              label: AppStrings.sosHistoryDeliveryStatus,
              value: deliveryInfo.label,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            _InfoRow(
              icon: Icons.my_location,
              color: hasLocation ? AppColors.success : AppColors.greyDark,
              label: AppStrings.sosHistoryLocation,
              value: hasLocation
                  ? AppStrings.sosHistoryLocationAvailable
                  : AppStrings.sosHistoryLocationUnavailable,
            ),
            if (event.successfulContactIds.isNotEmpty ||
                event.failedContactIds.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.paddingSM),
              _InfoRow(
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                label: AppStrings.sosHistorySuccessful,
                value: '${event.successfulContactIds.length}',
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              _InfoRow(
                icon: Icons.cancel_outlined,
                color: AppColors.error,
                label: AppStrings.sosHistoryFailed,
                value: '${event.failedContactIds.length}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small icon + label + value row used inside a history card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSM, color: color),
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

({String label, Color color, IconData icon}) _eventStatusInfo(
  EmergencyEventStatus status,
) {
  switch (status) {
    case EmergencyEventStatus.pending:
      return (
        label: 'Pending',
        color: AppColors.warning,
        icon: Icons.schedule,
      );
    case EmergencyEventStatus.locationFailed:
      return (
        label: 'Location failed',
        color: AppColors.error,
        icon: Icons.location_off_outlined,
      );
    case EmergencyEventStatus.ready:
      return (
        label: 'Ready',
        color: AppColors.success,
        icon: Icons.check_circle_outline,
      );
    case EmergencyEventStatus.cancelled:
      return (
        label: 'Cancelled',
        color: AppColors.greyDark,
        icon: Icons.cancel_outlined,
      );
    case EmergencyEventStatus.failed:
      return (
        label: 'Failed',
        color: AppColors.error,
        icon: Icons.error_outline,
      );
  }
}

({String label, Color color, IconData icon}) _deliveryStatusInfo(
  EmergencyAlertDeliveryStatus status,
) {
  switch (status) {
    case EmergencyAlertDeliveryStatus.ready:
      return (
        label: 'Not sent',
        color: AppColors.primaryBlue,
        icon: Icons.notifications_none,
      );
    case EmergencyAlertDeliveryStatus.sending:
      return (
        label: AppStrings.sosSending,
        color: AppColors.warning,
        icon: Icons.sync,
      );
    case EmergencyAlertDeliveryStatus.sent:
      return (
        label: AppStrings.sosSentSuccessfully,
        color: AppColors.success,
        icon: Icons.check_circle_outline,
      );
    case EmergencyAlertDeliveryStatus.partiallySent:
      return (
        label: AppStrings.sosPartiallySent,
        color: AppColors.warning,
        icon: Icons.warning_amber_outlined,
      );
    case EmergencyAlertDeliveryStatus.failed:
      return (
        label: AppStrings.sosDeliveryFailed,
        color: AppColors.error,
        icon: Icons.error_outline,
      );
  }
}
