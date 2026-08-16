import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeguard_ai/core/errors/exceptions.dart';
import 'package:lifeguard_ai/core/services/location_service.dart';
import 'package:lifeguard_ai/features/contacts/domain/entities/emergency_contact.dart';
import 'package:lifeguard_ai/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_event_repository.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_state.dart';

void main() {
  group('SosCubit', () {
    test('countdown ticks down and completes into a ready event', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
        );

        cubit.startSos();
        expect(cubit.state.status, SosStatus.countdown);
        expect(cubit.state.countdownSeconds, 5);

        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.countdownSeconds, 4);

        async.elapse(const Duration(seconds: 4));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.ready);
        expect(cubit.state.latitude, 37.4219999);
        expect(cubit.state.longitude, -122.0840575);
        expect(cubit.state.contactCount, 1);
        expect(cubit.state.event, isNotNull);
        expect(cubit.state.event!.status, EmergencyEventStatus.ready);
        expect(cubit.state.event!.contactIds, ['c1']);

        cubit.close();
      });
    });

    test('cancellation stops the countdown and never creates an event', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 2));
        expect(cubit.state.countdownSeconds, 3);

        cubit.cancelSos();
        expect(cubit.state.status, SosStatus.cancelled);
        expect(cubit.state.countdownSeconds, 0);

        // Time passing after cancel must not trigger the SOS.
        async.elapse(const Duration(seconds: 10));
        async.flushMicrotasks();
        expect(cubit.state.status, SosStatus.cancelled);
        expect(cubit.state.event, isNull);

        cubit.close();
      });
    });

    test('duplicate activation is prevented while an SOS is active', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
        );

        cubit.startSos();
        cubit.startSos(); // second press must be ignored
        expect(cubit.state.countdownSeconds, 5);

        async.elapse(const Duration(seconds: 1));
        expect(cubit.state.countdownSeconds, 4); // not reset by 2nd press

        cubit.close();
      });
    });

    test('no emergency contacts stops the workflow with noContacts', () {
      fakeAsync((async) {
        final cubit = _buildCubit(contacts: const [], location: _location());

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.noContacts);
        expect(cubit.state.event, isNull);
        expect(cubit.state.contactCount, 0);
        expect(cubit.state.message, isNotNull);

        cubit.close();
      });
    });

    test('location failure marks the workflow as failed', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
          locationError: true,
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.failed);
        expect(cubit.state.event, isNull);
        expect(cubit.state.message, isNotNull);

        cubit.close();
      });
    });

    test('permission failure marks failed with permissionDenied flag', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
          permissionError: true,
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.failed);
        expect(cubit.state.permissionDenied, isTrue);
        expect(cubit.state.event, isNull);

        cubit.close();
      });
    });

    test('contacts load failure marks the workflow as failed', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
          failContacts: true,
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.failed);
        expect(cubit.state.event, isNull);

        cubit.close();
      });
    });

    test('event persistence failure marks the workflow as failed', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
          failEvent: true,
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(cubit.state.status, SosStatus.failed);
        expect(cubit.state.event, isNull);

        cubit.close();
      });
    });

    test('reset returns to idle', () {
      fakeAsync((async) {
        final cubit = _buildCubit(
          contacts: [_contact()],
          location: _location(),
        );

        cubit.startSos();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();
        expect(cubit.state.status, SosStatus.ready);

        cubit.reset();
        expect(cubit.state.status, SosStatus.idle);
        expect(cubit.state.event, isNull);

        cubit.close();
      });
    });
  });
}

EmergencyContact _contact() {
  return const EmergencyContact(
    id: 'c1',
    name: 'Jane Doe',
    phoneNumber: '+1 555 123 4567',
    relationship: 'Spouse',
    isPrimary: true,
  );
}

LocationResult _location() {
  return LocationResult(
    latitude: 37.4219999,
    longitude: -122.0840575,
    timestamp: DateTime(2025, 1, 1, 10, 30),
    mapsLink:
        'https://www.google.com/maps/search/?api=1&query=37.4219999,-122.0840575',
  );
}

SosCubit _buildCubit({
  required List<EmergencyContact> contacts,
  required LocationResult location,
  bool failContacts = false,
  bool failEvent = false,
  bool locationError = false,
  bool permissionError = false,
}) {
  return SosCubit(
    contactsRepository: _FakeContactsRepository(contacts, fail: failContacts),
    eventRepository: _FakeEventRepository(fail: failEvent),
    locationService: _FakeLocationService(
      location,
      error: locationError,
      permissionError: permissionError,
    ),
  );
}

class _FakeContactsRepository implements ContactsRepository {
  _FakeContactsRepository(this.contacts, {this.fail = false});

  final List<EmergencyContact> contacts;
  final bool fail;

  @override
  Future<List<EmergencyContact>> getContacts() async {
    if (fail) throw Exception('contacts failed');
    return contacts;
  }

  @override
  Future<EmergencyContact> addContact(EmergencyContact contact) async =>
      contact;

  @override
  Future<EmergencyContact> updateContact(EmergencyContact contact) async =>
      contact;

  @override
  Future<void> deleteContact(String contactId) async {}

  @override
  Future<void> setPrimaryContact(String contactId) async {}
}

class _FakeEventRepository implements EmergencyEventRepository {
  _FakeEventRepository({this.fail = false});

  final bool fail;
  EmergencyEvent? created;

  @override
  Future<EmergencyEvent> createEvent(EmergencyEvent event) async {
    if (fail) throw Exception('event failed');
    created = event.copyWith(id: 'evt-1', userId: 'user-1');
    return created!;
  }

  @override
  Future<EmergencyEvent> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
  }) async {
    created = created?.copyWith(status: status, message: message);
    return created!;
  }

  @override
  Future<EmergencyEvent?> getEvent(String eventId) async => created;
}

class _FakeLocationService implements LocationService {
  _FakeLocationService(
    this.result, {
    this.error = false,
    this.permissionError = false,
  });

  final LocationResult result;
  final bool error;
  final bool permissionError;

  @override
  Future<LocationResult> getCurrentLocation() async {
    if (permissionError) {
      throw PermissionException(message: 'Permission denied');
    }
    if (error) {
      throw LocationException(message: 'Location failed');
    }
    return result;
  }
}
