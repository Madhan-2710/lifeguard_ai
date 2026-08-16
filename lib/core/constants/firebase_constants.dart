/// Firebase collection names, field names, and configuration constants
class FirebaseConstants {
  FirebaseConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String emergencyContactsCollection = 'emergency_contacts';
  static const String medicinesCollection = 'medicines';
  static const String healthRecordsCollection = 'health_records';
  static const String chatMessagesCollection = 'chat_messages';
  static const String sosAlertsCollection = 'sos_alerts';
  static const String fallEventsCollection = 'fall_events';
  static const String medicationLogsCollection = 'medication_logs';

  // User Fields
  static const String userId = 'userId';
  static const String email = 'email';
  static const String fullName = 'fullName';
  static const String phoneNumber = 'phoneNumber';
  static const String photoUrl = 'photoUrl';
  static const String bloodType = 'bloodType';
  static const String allergies = 'allergies';
  static const String medicalConditions = 'medicalConditions';
  static const String emergencyInstructions = 'emergencyInstructions';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String isOnboardingComplete = 'isOnboardingComplete';

  // Emergency Contact Fields
  static const String contactId = 'contactId';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String relationship = 'relationship';
  static const String isPrimary = 'isPrimary';

  // Medicine Fields
  static const String medicineId = 'medicineId';
  static const String medicineName = 'medicineName';
  static const String dosage = 'dosage';
  static const String frequency = 'frequency';
  static const String reminderTimes = 'reminderTimes';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String isActive = 'isActive';
  static const String notes = 'notes';

  // SOS Alert Fields
  static const String alertId = 'alertId';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String timestamp = 'timestamp';
  static const String status = 'status';
  static const String alertedContacts = 'alertedContacts';
  static const String isResolved = 'isResolved';

  // Fall Event Fields
  static const String eventId = 'eventId';
  static const String fallTimestamp = 'fallTimestamp';
  static const String confidenceScore = 'confidenceScore';
  static const String wasConfirmed = 'wasConfirmed';
  static const String alertSent = 'alertSent';

  // Chat Message Fields
  static const String messageId = 'messageId';
  static const String content = 'content';
  static const String isUser = 'isUser';
  static const String isEmergency = 'isEmergency';
  static const String sentiment = 'sentiment';
  static const String language = 'language';
  static const String sentAt = 'sentAt';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String healthRecordImagesPath = 'health_records';

  // Notification Channels
  static const String medicineChannelId = 'medicine_reminders';
  static const String medicineChannelName = 'Medicine Reminders';
  static const String medicineChannelDescription = 'Notifications for medicine reminders';

  static const String emergencyChannelId = 'emergency_alerts';
  static const String emergencyChannelName = 'Emergency Alerts';
  static const String emergencyChannelDescription = 'Notifications for emergency alerts';

  static const String fallDetectionChannelId = 'fall_detection';
  static const String fallDetectionChannelName = 'Fall Detection';
  static const String fallDetectionChannelDescription = 'Notifications for fall detection alerts';

  // Shared Preferences Keys
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefUserId = 'user_id';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefFallDetectionEnabled = 'fall_detection_enabled';
  static const String prefSosContacts = 'sos_contacts';
  static const String prefLanguage = 'app_language';
  static const String prefDarkMode = 'dark_mode';
  static const String prefCooldownEndTime = 'fall_cooldown_end_time';

  // Collection Queries
  static const int maxRecentMessages = 50;
  static const int maxHealthRecords = 100;
  static const int sosTimeoutSeconds = 30;
  static const int fallCooldownSeconds = 60;
  static const int fallConfirmTimeoutSeconds = 15;

  // App Configuration
  static const String appVersion = '1.0.0';
  static const String countryCode = '+1'; // Default country code
  static const double emergencyRadiusKm = 10.0;
}

