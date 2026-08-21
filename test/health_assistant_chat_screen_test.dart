import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeguard_ai/core/constants/app_strings.dart';
import 'package:lifeguard_ai/core/di/service_locator.dart';
import 'package:lifeguard_ai/core/services/location_service.dart';
import 'package:lifeguard_ai/features/contacts/domain/entities/emergency_contact.dart';
import 'package:lifeguard_ai/features/contacts/domain/repositories/contacts_repository.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/entities/health_assistant_response.dart';
import 'package:lifeguard_ai/features/health_assistant/domain/repositories/health_assistant_repository.dart';
import 'package:lifeguard_ai/features/health_assistant/presentation/cubit/health_assistant_cubit.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_alert_delivery.dart';
import 'package:lifeguard_ai/features/sos/domain/entities/emergency_event.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_alert_delivery_repository.dart';
import 'package:lifeguard_ai/features/sos/domain/repositories/emergency_event_repository.dart';
import 'package:lifeguard_ai/features/sos/presentation/cubit/sos_cubit.dart';
import 'package:lifeguard_ai/presentation/emergency/sos_screen.dart';
import 'package:lifeguard_ai/presentation/health_assistant/chat_screen.dart';
import 'package:lifeguard_ai/presentation/router/app_router.dart';

void main() {
  group('ChatView', () {
    testWidgets('renders welcome message and safety disclaimer', (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      expect(find.text(AppStrings.healthAssistantWelcome), findsOneWidget);
      expect(find.text(AppStrings.healthAssistantDisclaimer), findsOneWidget);
      expect(find.text(AppStrings.typeMessage), findsOneWidget);
      cubit.close();
    });

    testWidgets('typing and sending appends a user bubble and a response',
        (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'How do I treat a small cut?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('How do I treat a small cut?'), findsOneWidget);
      expect(find.text('Guidance for: How do I treat a small cut?'), findsOneWidget);
      cubit.close();
    });

    testWidgets('quick action chip sends a message', (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.tap(find.widgetWithText(ActionChip, 'Chest Pain'));
      await tester.pumpAndSettle();

      expect(find.text('Chest Pain'), findsWidgets); // chip + user bubble
      expect(find.text('Guidance for: Chest Pain'), findsOneWidget);
      cubit.close();
    });

    testWidgets('shows responding indicator while the assistant responds',
        (tester) async {
      final cubit = HealthAssistantCubit(repository: _SlowRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'chest pain');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text(AppStrings.healthAssistantResponding), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text(AppStrings.healthAssistantResponding), findsNothing);
      cubit.close();
    });

    testWidgets('failed send shows error banner and retry recovers',
        (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository(failFirst: true));
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'bleeding');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.healthAssistantError), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.healthAssistantError), findsNothing);
      expect(find.text('Guidance for: bleeding'), findsOneWidget);
      cubit.close();
    });

    testWidgets('serious response shows Open Emergency SOS banner',
        (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'I have chest pain');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.openEmergencySos), findsOneWidget);
      cubit.close();
    });

    testWidgets('general response does not show the SOS banner', (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'What is first aid?');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.openEmergencySos), findsNothing);
      cubit.close();
    });

    testWidgets('Open Emergency SOS navigates to the existing SOS screen',
        (tester) async {
      // The real SOSScreen builds its cubit from GetIt, so register the
      // SOS dependency chain with fakes for this test.
      sl.registerFactory<SosCubit>(
        () => SosCubit(
          contactsRepository: _FakeContactsRepository(),
          eventRepository: _FakeEventRepository(),
          locationService: _FakeLocationService(),
          alertDeliveryRepository: _FakeDeliveryRepository(),
        ),
      );
      addTearDown(() => sl.unregister<SosCubit>());

      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrapWithRouter(cubit));

      await tester.enterText(find.byType(TextField), 'I have chest pain');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.openEmergencySos));
      await tester.pumpAndSettle();

      expect(find.byType(SOSScreen), findsOneWidget);
      cubit.close();
    });

    testWidgets('clear conversation resets to the welcome message',
        (tester) async {
      final cubit = HealthAssistantCubit(repository: _FakeRepository());
      await tester.pumpWidget(_wrap(cubit));

      await tester.enterText(find.byType(TextField), 'fall');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('Guidance for: fall'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.confirm));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.healthAssistantWelcome), findsOneWidget);
      expect(find.text('Guidance for: fall'), findsNothing);
      cubit.close();
    });
  });
}

class _FakeRepository implements HealthAssistantRepository {
  _FakeRepository({this.failFirst = false});

  final bool failFirst;
  bool _firstCall = true;

  @override
  Future<HealthAssistantResponse> getResponse(String userMessage) async {
    if (failFirst && _firstCall) {
      _firstCall = false;
      throw Exception('network error');
    }
    final text = userMessage.toLowerCase();
    final serious = text.contains('chest') ||
        text.contains('bleed') ||
        text.contains('breath') ||
        text.contains('unconscious') ||
        text.contains('fall');
    return HealthAssistantResponse(
      text: 'Guidance for: $userMessage',
      sosRecommended: serious,
    );
  }
}

class _SlowRepository implements HealthAssistantRepository {
  @override
  Future<HealthAssistantResponse> getResponse(String userMessage) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return HealthAssistantResponse(text: 'ok');
  }
}

Widget _wrap(HealthAssistantCubit cubit) {
  return BlocProvider<HealthAssistantCubit>(
    create: (_) => cubit,
    child: const MaterialApp(home: ChatView()),
  );
}

Widget _wrapWithRouter(HealthAssistantCubit cubit) {
  final router = GoRouter(
    initialLocation: AppRoutes.healthAssistant,
    routes: [
      GoRoute(
        path: AppRoutes.healthAssistant,
        name: 'healthAssistant',
        builder: (context, state) => const ChatView(),
      ),
      GoRoute(
        path: AppRoutes.sos,
        name: 'sos',
        builder: (context, state) => const SOSScreen(),
      ),
    ],
  );
  return BlocProvider<HealthAssistantCubit>(
    create: (_) => cubit,
    child: MaterialApp.router(routerConfig: router),
  );
}
class _FakeContactsRepository implements ContactsRepository {
  @override
  Future<List<EmergencyContact>> getContacts() async => const [];

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
  @override
  Future<EmergencyEvent> createEvent(EmergencyEvent event) async => event;

  @override
  Future<EmergencyEvent> updateEventStatus(
    String eventId,
    EmergencyEventStatus status, {
    String? message,
  }) async => throw UnimplementedError();

  @override
  Future<EmergencyEvent?> getEvent(String eventId) async => null;

  @override
  Future<List<EmergencyEvent>> getEventHistory() async => const [];
}

class _FakeLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async => LocationResult(
        latitude: 37.4219999,
        longitude: -122.0840575,
        timestamp: DateTime(2025, 1, 1, 10, 30),
        mapsLink:
            'https://www.google.com/maps/search/?api=1&query=37.4219999,-122.0840575',
      );
}

class _FakeDeliveryRepository implements EmergencyAlertDeliveryRepository {
  @override
  Future<EmergencyAlertDeliveryResult> deliverEmergencyAlert({
    required String eventId,
  }) async {
    return EmergencyAlertDeliveryResult(
      eventId: eventId,
      status: EmergencyAlertDeliveryStatus.sent,
    );
  }
}
