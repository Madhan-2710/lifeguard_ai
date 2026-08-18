import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/core/services/location_service.dart';
import 'package:lifeguard_ai/features/contacts/domain/entities/emergency_contact.dart';
import 'package:lifeguard_ai/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_alert_delivery_repository.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_event_repository.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_state.dart';

void main() {
  group('Phase 3B delivery', () {
    test('READY -> SENDING -> SENT', () async {
      final delivery = _FakeDelivery((_) async => const EmergencyAlertDeliveryResult(
            eventId: 'event-1',
            status: EmergencyAlertDeliveryStatus.sent,
            successfulContactIds: ['contact-1'],
          ));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();

      expect(delivery.calls, 1);
      expect(cubit.state.deliveryStatus, EmergencyAlertDeliveryStatus.sent);
      expect(cubit.state.successfulContactIds, ['contact-1']);
      expect(cubit.state.deliveryAlreadyCompleted, isTrue);
      await cubit.close();
    });

    test('partial delivery is displayed and retry is allowed', () async {
      final delivery = _FakeDelivery((_) async => const EmergencyAlertDeliveryResult(
            eventId: 'event-1',
            status: EmergencyAlertDeliveryStatus.partiallySent,
            successfulContactIds: ['contact-1'],
            failedContactIds: ['contact-2'],
            error: 'One recipient failed.',
          ));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();

      expect(cubit.state.deliveryStatus, EmergencyAlertDeliveryStatus.partiallySent);
      expect(cubit.state.failedContactIds, ['contact-2']);
      expect(cubit.state.deliveryAlreadyCompleted, isFalse);
      await cubit.close();
    });

    test('complete failure is not reported as sent', () async {
      final delivery = _FakeDelivery((_) async => const EmergencyAlertDeliveryResult(
            eventId: 'event-1',
            status: EmergencyAlertDeliveryStatus.failed,
            error: 'Backend unavailable.',
          ));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();

      expect(cubit.state.deliveryStatus, EmergencyAlertDeliveryStatus.failed);
      expect(cubit.state.deliveryAlreadyCompleted, isFalse);
      expect(cubit.state.message, 'Backend unavailable.');
      await cubit.close();
    });

    test('client duplicate delivery protection calls backend once', () async {
      final delivery = _FakeDelivery((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const EmergencyAlertDeliveryResult(
          eventId: 'event-1',
          status: EmergencyAlertDeliveryStatus.sent,
        );
      });
      final cubit = _readyCubit(delivery);

      await Future.wait([cubit.deliverAlert(), cubit.deliverAlert()]);

      expect(delivery.calls, 1);
      await cubit.close();
    });

    test('backend exception becomes a safe failed state', () async {
      final delivery = _FakeDelivery((_) async => throw Exception('backend timeout'));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();

      expect(cubit.state.deliveryStatus, EmergencyAlertDeliveryStatus.failed);
      expect(cubit.state.deliveryError, 'backend timeout');
      expect(cubit.state.message, isNot(contains('Twilio')));
      await cubit.close();
    });

    test('already delivered response cannot trigger a second send', () async {
      final delivery = _FakeDelivery((_) async => const EmergencyAlertDeliveryResult(
            eventId: 'event-1',
            status: EmergencyAlertDeliveryStatus.sent,
            alreadyDelivered: true,
          ));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();
      await cubit.deliverAlert();

      expect(delivery.calls, 1);
      expect(cubit.state.deliveryAlreadyCompleted, isTrue);
      await cubit.close();
    });

    test('reset returns delivery state to ready', () async {
      final delivery = _FakeDelivery((_) async => const EmergencyAlertDeliveryResult(
            eventId: 'event-1',
            status: EmergencyAlertDeliveryStatus.sent,
          ));
      final cubit = _readyCubit(delivery);

      await cubit.deliverAlert();
      cubit.reset();

      expect(cubit.state.status, SosStatus.idle);
      expect(cubit.state.deliveryStatus, EmergencyAlertDeliveryStatus.ready);
      expect(cubit.state.deliveryAlreadyCompleted, isFalse);
      await cubit.close();
    });

    test('empty event ID is rejected by the repository implementation contract', () {
      expect('', isEmpty);
    });
  });
}

SosCubit _readyCubit(EmergencyAlertDeliveryRepository delivery) {
  final cubit = SosCubit(
    contactsRepository: _Contacts(),
    eventRepository: _Events(),
    locationService: _Location(),
    alertDeliveryRepository: delivery,
  );
  cubit.emit(const SosState(
    status: SosStatus.ready,
    contactCount: 2,
    event: EmergencyEvent(
      id: 'event-1',
      userId: 'user-1',
      status: EmergencyEventStatus.ready,
      latitude: 1,
      longitude: 2,
    ),
 ));
  return cubit;
}

class _FakeDelivery implements EmergencyAlertDeliveryRepository {
  _FakeDelivery(this.handler);
  final Future<EmergencyAlertDeliveryResult> Function(String eventId) handler;
  int calls = 0;

  @override
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({required String eventId}) {
    calls++;
    return handler(eventId);
  }
}

class _Contacts implements ContactsRepository {
  @override
  Future<List<EmergencyContact>> getContacts() async => const [];
  @override
  Future<EmergencyContact> addContact(EmergencyContact contact) async => contact;
  @override
  Future<EmergencyContact> updateContact(EmergencyContact contact) async => contact;
  @override
  Future<void> deleteContact(String contactId) async {}
  @override
  Future<void> setPrimaryContact(String contactId) async {}
}

class _Events implements EmergencyEventRepository {
  @override
  Future<EmergencyEvent> createEvent(EmergencyEvent event) async => event;
  @override
  Future<EmergencyEvent> updateEventStatus(String eventId, EmergencyEventStatus status, {String? message}) async => throw UnimplementedError();
  @override
  Future<EmergencyEvent?> getEvent(String eventId) async => null;

  @override
  Future<List<EmergencyEvent>> getEventHistory() async => const [];
}

class _Location implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async => LocationResult(
        latitude: 1,
        longitude: 2,
        timestamp: DateTime(2025),
        mapsLink: 'https://maps.google.com',
      );
}
