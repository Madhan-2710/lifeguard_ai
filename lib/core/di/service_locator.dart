import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/firebase_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_authentication_status.dart';
import '../../features/auth/domain/usecases/forgot_password.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/contacts/data/datasources/contacts_data_source.dart';
import '../../features/contacts/data/repositories/contacts_repository_impl.dart';
import '../../features/contacts/domain/repositories/contacts_repository.dart';
import '../../features/contacts/presentation/cubit/contacts_cubit.dart';
import '../../features/health_assistant/data/datasources/health_assistant_data_source.dart';
import '../../features/health_assistant/data/datasources/llm_health_assistant_config.dart';
import '../../features/health_assistant/data/datasources/llm_health_assistant_data_source.dart';
import '../../features/health_assistant/data/datasources/local_health_assistant_data_source.dart';
import '../../features/health_assistant/data/repositories/health_assistant_repository_impl.dart';
import '../../features/health_assistant/domain/repositories/health_assistant_repository.dart';
import '../../features/health_assistant/presentation/cubit/health_assistant_cubit.dart';
import '../../features/medical_profile/data/datasources/medical_profile_data_source.dart';
import '../../features/medical_profile/data/repositories/medical_profile_repository_impl.dart';
import '../../features/medical_profile/domain/repositories/medical_profile_repository.dart';
import '../../features/medical_profile/presentation/cubit/medical_profile_cubit.dart';
import '../../features/medicine/data/datasources/medicines_data_source.dart';
import '../../features/medicine/data/repositories/medicines_repository_impl.dart';
import '../../features/medicine/domain/repositories/medicines_repository.dart';
import '../../features/medicine/presentation/cubit/medicines_cubit.dart';
import '../services/medicine_reminder_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../features/sos/data/datasources/emergency_alert_delivery_data_source.dart';
import '../../features/sos/data/datasources/emergency_event_data_source.dart';
import '../../features/sos/data/repositories/emergency_alert_delivery_repository_impl.dart';
import '../../features/sos/data/repositories/emergency_event_repository_impl.dart';
import '../../features/sos/domain/repositories/emergency_alert_delivery_repository.dart';
import '../../features/sos/domain/repositories/emergency_event_repository.dart';
import '../../features/sos/presentation/cubit/sos_cubit.dart';
import '../../features/sos/presentation/cubit/sos_history_cubit.dart';
import '../services/location_service.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<FirebaseAuthDataSource>()),
  );

  sl.registerLazySingleton<Login>(
    () => Login(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<Register>(
    () => Register(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<Logout>(
    () => Logout(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ForgotPassword>(
    () => ForgotPassword(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetCurrentUser>(
    () => GetCurrentUser(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<CheckAuthenticationStatus>(
    () => CheckAuthenticationStatus(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      login: sl<Login>(),
      register: sl<Register>(),
      logout: sl<Logout>(),
      forgotPassword: sl<ForgotPassword>(),
      checkAuthenticationStatus: sl<CheckAuthenticationStatus>(),
    ),
  );

  sl.registerLazySingleton<ContactsDataSource>(
    () => ContactsDataSourceImpl(),
  );

  sl.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(sl<ContactsDataSource>()),
  );

  sl.registerLazySingleton<ContactsCubit>(
    () => ContactsCubit(contactsRepository: sl<ContactsRepository>()),
  );

  sl.registerLazySingleton<LocationService>(
    () => GeolocatorLocationService(),
  );

  sl.registerLazySingleton<EmergencyEventDataSource>(
    () => EmergencyEventDataSourceImpl(),
  );

  sl.registerLazySingleton<EmergencyEventRepository>(
    () => EmergencyEventRepositoryImpl(sl<EmergencyEventDataSource>()),
  );

  // Factory: a fresh SosCubit per screen visit, disposed with the screen.
  sl.registerLazySingleton<FirebaseFunctions>(
    () => FirebaseFunctions.instance,
  );

  sl.registerLazySingleton<EmergencyAlertDeliveryDataSource>(
    () => EmergencyAlertDeliveryDataSourceImpl(functions: sl<FirebaseFunctions>()),
  );

  sl.registerLazySingleton<EmergencyAlertDeliveryRepository>(
    () => EmergencyAlertDeliveryRepositoryImpl(
      sl<EmergencyAlertDeliveryDataSource>(),
    ),
  );

  sl.registerFactory<SosCubit>(
    () => SosCubit(
      contactsRepository: sl<ContactsRepository>(),
      eventRepository: sl<EmergencyEventRepository>(),
      locationService: sl<LocationService>(),
      alertDeliveryRepository: sl<EmergencyAlertDeliveryRepository>(),
    ),
  );

  // Factory: a fresh SosHistoryCubit per screen visit, disposed with the screen.
  sl.registerFactory<SosHistoryCubit>(
    () => SosHistoryCubit(eventRepository: sl<EmergencyEventRepository>()),
  );

  // AI Health Assistant (Phase 5B) — provider selection via config.
  // Defaults to the local, offline-first engine. When the LLM provider is
  // selected AND a credential is available, the LLM data source is used with
  // automatic fallback to local mode on timeout, network failure, or
  // malformed responses.
  final llmConfig = LlmHealthAssistantConfig.fromEnvironment();
  final HealthAssistantDataSource healthAssistantDataSource = llmConfig.useLlm
      ? LlmHealthAssistantDataSource(config: llmConfig)
      : const LocalHealthAssistantDataSource();
  sl.registerLazySingleton<HealthAssistantDataSource>(
    () => healthAssistantDataSource,
  );

  sl.registerLazySingleton<HealthAssistantRepository>(
    () => HealthAssistantRepositoryImpl(sl<HealthAssistantDataSource>()),
  );

  // Factory: a fresh HealthAssistantCubit per screen visit (conversation state).
  sl.registerFactory<HealthAssistantCubit>(
    () => HealthAssistantCubit(repository: sl<HealthAssistantRepository>()),
  );

  // Medical Profile (Phase 6A)
  sl.registerLazySingleton<MedicalProfileDataSource>(
    () => MedicalProfileDataSourceImpl(),
  );

  sl.registerLazySingleton<MedicalProfileRepository>(
    () => MedicalProfileRepositoryImpl(sl<MedicalProfileDataSource>()),
  );

  sl.registerLazySingleton<MedicalProfileCubit>(
    () => MedicalProfileCubit(repository: sl<MedicalProfileRepository>()),
  );

  // Medicines (Phase 6A)
  sl.registerLazySingleton<MedicinesDataSource>(
    () => MedicinesDataSourceImpl(),
  );

  sl.registerLazySingleton<MedicinesRepository>(
    () => MedicinesRepositoryImpl(sl<MedicinesDataSource>()),
  );

  sl.registerLazySingleton<MedicinesCubit>(
    () => MedicinesCubit(repository: sl<MedicinesRepository>()),
  );

  // Medicine reminders (Phase 6A)
  sl.registerLazySingleton<MedicineReminderService>(
    () => MedicineReminderService(),
  );
}
