import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../features/sos/domain/entities/emergency_alert_delivery.dart';
import '../../features/sos/domain/entities/emergency_event.dart';

/// SOS Event Detail screen (Phase 4B).
///
/// Shows the full details of a single [EmergencyEvent] from SOS History:
/// date/time, event status, delivery status, successful/failed contact
/// counts, delivery error, coordinates, a Google Maps button when a
/// location exists, and the event id.
///
/// Reuses [EmergencyEvent] — no new entity or repository is introduced.
/// All optional fields are rendered with safe fallbacks so old events with
/// missing fields never crash the screen.
class SosHistoryDetailScreen extends StatelessWidget {
  const SosHistoryDetailScreen({super.key, required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sosHistoryDetailTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderCard(event: event),
            const SizedBox(height: AppDimensions.paddingMD),
            _StatusCard(event: event),
            const SizedBox(height: AppDimensions.paddingMD),
            _DeliveryCard(event: event),
            const SizedBox(height: AppDimensions.paddingMD),
            _LocationCard(event: event),
            const SizedBox(height: AppDimensions.paddingMD),
            _EventIdCard(event: event),
          ],
        ),
      ),
    );
  }
}

/// Date/time header with the SOS icon.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
          children: [
            const Icon(
              Icons.sos,
              size: AppDimensions.iconLG,
              color: AppColors.emergencyRed,
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.sosHistoryDetailEventTime,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    event.timestamp != null
                        ? Helpers.formatDateTime(event.timestamp!)
                        : AppStrings.sosHistoryTimeUnavailable,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Event status and delivery status badges.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    final eventInfo = _eventStatusInfo(event.status);
    final deliveryInfo = _deliveryStatusInfo(event.deliveryStatus);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sosHistoryDetailStatus,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            _StatusBadge(
              icon: eventInfo.icon,
              color: eventInfo.color,
              label: AppStrings.sosHistoryEventStatus,
              value: eventInfo.label,
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            _StatusBadge(
              icon: deliveryInfo.icon,
              color: deliveryInfo.color,
              label: AppStrings.sosHistoryDeliveryStatus,
              value: deliveryInfo.label,
            ),
          ],
        ),
      ),
    );
  }
}

/// Successful/failed contact counts and delivery error (when available).
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    final hasDeliveryData =
        event.successfulContactIds.isNotEmpty ||
        event.failedContactIds.isNotEmpty ||
        event.deliveryError != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sosHistoryDetailDelivery,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            if (!hasDeliveryData)
              Text(
                AppStrings.sosHistoryDetailNoDeliveryData,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
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
              if (event.deliveryError != null &&
                  event.deliveryError!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingSM),
                _InfoRow(
                  icon: Icons.error_outline,
                  color: AppColors.error,
                  label: AppStrings.sosHistoryDetailDeliveryError,
                  value: event.deliveryError!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Coordinates and Google Maps button when a location exists.
class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.event});

  final EmergencyEvent event;

  bool get _hasLocation =>
      (event.latitude != null && event.longitude != null) ||
      (event.locationLink != null && event.locationLink!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.sosHistoryDetailLocation,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            if (!_hasLocation)
              Text(
                AppStrings.sosHistoryLocationUnavailable,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              if (event.latitude != null && event.longitude != null)
                _InfoRow(
                  icon: Icons.my_location,
                  color: AppColors.primaryBlue,
                  label: AppStrings.sosHistoryDetailCoordinates,
                  value:
                      '${event.latitude!.toStringAsFixed(5)}, '
                      '${event.longitude!.toStringAsFixed(5)}',
                ),
              const SizedBox(height: AppDimensions.paddingMD),
              CustomButton(
                label: AppStrings.sosHistoryDetailOpenMaps,
                icon: Icons.map_outlined,
                variant: ButtonVariant.secondary,
                onPressed: () => _openMaps(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    final uri = _mapsUri();
    if (uri == null) return;
    final messenger = ScaffoldMessenger.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white),
              const SizedBox(width: AppDimensions.paddingSM),
              Expanded(child: Text(AppStrings.sosHistoryDetailMapsError)),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Uri? _mapsUri() {
    if (event.latitude != null && event.longitude != null) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${event.latitude},${event.longitude}',
      );
    }
    final link = event.locationLink;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri != null && uri.hasScheme) return uri;
    }
    return null;
  }
}

/// Event id card.
class _EventIdCard extends StatelessWidget {
  const _EventIdCard({required this.event});

  final EmergencyEvent event;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: _InfoRow(
          icon: Icons.tag,
          color: AppColors.greyDark,
          label: AppStrings.sosHistoryDetailEventId,
          value: event.id,
        ),
      ),
    );
  }
}

/// A colored status badge row (icon + label + value).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconSM, color: color),
          const SizedBox(width: AppDimensions.paddingSM),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSM),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: AppDimensions.fontSM,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon + label + value row.
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
