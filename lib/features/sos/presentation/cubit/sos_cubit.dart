import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/location_service.dart';
import '../../../contacts/domain/entities/emergency_contact.dart';
import '../../domain/entities/emergency_alert_delivery.dart';
import '../../domain/repositories/emergency_alert_delivery_repository.dart';
import '../../../contacts/domain/repositories/contacts_repository.dart';
import '../../domain/entities/emergency_event.dart';
import '../../domain/repositories/emergency_event_repository.dart';
import 'sos_state.dart';

/// Orchestrates the core SOS workflow:
///
/// press SOS → 5s countdown (cancellable) → GPS location → load emergency
/// contacts via the domain repository → prepare + persist an emergency event.
///
/// SOS deliberately depends on [ContactsRepository] (domain layer), NOT on
/// `ContactsCubit`, keeping Contacts and SOS loosely coupled.
class SosCubit extends Cubit<SosState> {
  SosCubit({
    required ContactsRepository contactsRepository,
    required EmergencyEventRepository eventRepository,
    required LocationService locationService,
    EmergencyAlertDeliveryRepository? alertDeliveryRepository,
    this.countdownDuration = const Duration(seconds: 5),
  })  : _repository = contactsRepository,
        _eventRepo = eventRepository,
        _location = locationService,
        _deliveryRepository = alertDeliveryRepository,
        super(const SosState());

  final ContactsRepository _repository;
  final EmergencyEventRepository _eventRepo;
  final LocationService _location;
  final EmergencyAlertDeliveryRepository? _deliveryRepository;
  bool _deliveryInFlight = false;

  /// Length of the cancellable countdown before the SOS executes.
  final Duration countdownDuration;

  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  bool _executing = false;
  bool _cancelled = false;

  /// Starts the SOS countdown.
  ///
  /// No-op when an SOS is already active (prevents duplicate activation).
  void startSos() {
    if (state.isActive || _executing) return;

    _cancelled = false;
    _remainingSeconds = countdownDuration.inSeconds;
    emit(
      state.copyWith(
        status: SosStatus.countdown,
        countdownSeconds: _remainingSeconds,
        message: null,
        event: null,
        latitude: null,
        longitude: null,
        timestamp: null,
        locationLink: null,
        contactCount: 0,
        permissionDenied: false,
      ),
    );

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _executeSos();
      } else {
        emit(state.copyWith(countdownSeconds: _remainingSeconds));
      }
    });
  }

  /// Cancels an active SOS (countdown or in-flight preparation).
  void cancelSos() {
    if (!state.isActive) return;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _cancelled = true;
    emit(
      state.copyWith(
        status: SosStatus.cancelled,
        countdownSeconds: 0,
        message: AppStrings.sosCancelled,
      ),
    );
  }

  /// Resets the cubit to its initial idle state.
  void reset() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _cancelled = false;
    _executing = false;
    emit(const SosState());
  }

  Future<void> _executeSos() async {
    if (_executing) return;
    _executing = true;
    try {
      // 1. GPS location.
      emit(state.copyWith(status: SosStatus.locating, countdownSeconds: 0));
      final LocationResult location;
      try {
        location = await _location.getCurrentLocation();
      } on PermissionException catch (e) {
        if (_cancelled) return;
        emit(
          state.copyWith(
            status: SosStatus.failed,
            message: e.message,
            permissionDenied: true,
          ),
        );
        return;
      } on LocationException catch (e) {
        if (_cancelled) return;
        emit(state.copyWith(status: SosStatus.failed, message: e.message));
        return;
      } catch (_) {
        if (_cancelled) return;
        emit(
          state.copyWith(
            status: SosStatus.failed,
            message: AppStrings.sosLocationError,
          ),
        );
        return;
      }
      if (_cancelled) return;

      // 2. Emergency contacts via the domain repository.
      emit(
        state.copyWith(
          status: SosStatus.loadingContacts,
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: location.timestamp,
          locationLink: location.mapsLink,
        ),
      );
      final List<EmergencyContact> contacts;
      try {
        contacts = await _repository.getContacts();
      } catch (_) {
        if (_cancelled) return;
        emit(
          state.copyWith(
            status: SosStatus.failed,
            message: AppStrings.sosContactsError,
          ),
        );
        return;
      }
      if (_cancelled) return;

      if (contacts.isEmpty) {
        // Stop the workflow — never claim an alert was sent.
        emit(
          state.copyWith(
            status: SosStatus.noContacts,
            contactCount: 0,
            message: AppStrings.sosNoContactsMessage,
          ),
        );
        return;
      }

      // 3. Prepare + persist the emergency event (status: ready).
      emit(
        state.copyWith(
          status: SosStatus.preparing,
          contactCount: contacts.length,
        ),
      );
      final event = EmergencyEvent(
        id: '',
        userId: '',
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: location.timestamp,
        locationLink: location.mapsLink,
        contactIds: contacts.map((c) => c.id).toList(),
        status: EmergencyEventStatus.ready,
      );
      final EmergencyEvent saved;
      try {
        saved = await _eventRepo.createEvent(event);
      } catch (_) {
        if (_cancelled) return;
        emit(
          state.copyWith(
            status: SosStatus.failed,
            message: AppStrings.sosEventError,
          ),
        );
        return;
      }
      if (_cancelled) return;

      emit(
        state.copyWith(
          status: SosStatus.ready,
          event: saved,
          message: AppStrings.sosEventPrepared,
          deliveryStatus: EmergencyAlertDeliveryStatus.ready,
          deliveryInProgress: false,
          deliveryAlreadyCompleted: false,
        ),
      );
    } finally {
      _executing = false;
    }
  }

  /// Requests server-side SMS delivery for the current READY event.
  /// The client guard is supplementary; backend idempotency is authoritative.
  Future<void> deliverAlert() async {
    final eventId = state.event?.id;
    final repository = _deliveryRepository;
    if (eventId == null || eventId.isEmpty || repository == null) {
      emit(state.copyWith(
        deliveryStatus: EmergencyAlertDeliveryStatus.failed,
        deliveryError: 'Emergency alert delivery is not configured.',
      ));
      return;
    }
    if (state.status != SosStatus.ready ||
        _deliveryInFlight ||
        state.isDeliveryActive ||
        state.deliveryAlreadyCompleted) {
      return;
    }

    _deliveryInFlight = true;
    emit(state.copyWith(
      deliveryStatus: EmergencyAlertDeliveryStatus.sending,
      deliveryInProgress: true,
      deliveryError: null,
    ));

    try {
      final result = await repository.deliverEmergencyAlert(eventId: eventId);
      emit(state.copyWith(
        deliveryStatus: result.status,
        successfulContactIds: result.successfulContactIds,
        failedContactIds: result.failedContactIds,
        deliveryError: result.error,
        deliveryAlreadyCompleted: result.alreadyDelivered || result.isSuccessful,
        deliveryInProgress: false,
        message: result.error ?? _deliveryMessage(result.status),
      ));
    } catch (error) {
      emit(state.copyWith(
        deliveryStatus: EmergencyAlertDeliveryStatus.failed,
        deliveryError: _safeDeliveryError(error),
        deliveryInProgress: false,
        message: AppStrings.sosDeliveryFailed,
      ));
    } finally {
      _deliveryInFlight = false;
    }
  }

  String _deliveryMessage(EmergencyAlertDeliveryStatus status) {
    switch (status) {
      case EmergencyAlertDeliveryStatus.ready:
        return AppStrings.sosEventPrepared;
      case EmergencyAlertDeliveryStatus.sending:
        return AppStrings.sosSending;
      case EmergencyAlertDeliveryStatus.sent:
        return AppStrings.sosSentSuccessfully;
      case EmergencyAlertDeliveryStatus.partiallySent:
        return AppStrings.sosPartiallySent;
      case EmergencyAlertDeliveryStatus.failed:
        return AppStrings.sosDeliveryFailed;
    }
  }

  String _safeDeliveryError(Object error) {
    final text = error.toString();
    if (text.contains('Twilio') || text.contains('token') || text.contains('SID')) {
      return AppStrings.sosDeliveryFailed;
    }
    return text.replaceFirst('Exception: ', '');
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    return super.close();
  }
}
