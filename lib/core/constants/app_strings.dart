/// All string constants used in the LifeGuard AI app
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'LifeGuard AI';
  static const String appTagline = 'Your AI-Powered Emergency Healthcare Assistant';

  // Splash
  static const String splashTitle = 'LifeGuard AI';
  static const String splashSubtitle = 'Your Health, Our Priority';

  // Onboarding
  static const String onboardingTitle1 = 'AI Health Assistant';
  static const String onboardingDesc1 = 'Get instant health guidance powered by AI, anytime, anywhere.';
  static const String onboardingTitle2 = 'Emergency SOS';
  static const String onboardingDesc2 = 'One tap emergency alerts with live location sharing to your trusted contacts.';
  static const String onboardingTitle3 = 'Fall Detection';
  static const String onboardingDesc3 = 'Smart sensors detect falls and automatically alert your emergency contacts.';
  static const String onboardingTitle4 = 'Medicine Reminder';
  static const String onboardingDesc4 = 'Never miss your medications with smart reminders and tracking.';
  static const String getStarted = 'Get Started';
  static const String next = 'Next';
  static const String skip = 'Skip';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String logout = 'Logout';
  static const String resetPassword = 'Reset Password';
  static const String sendResetLink = 'Send Reset Link';
  static const String orContinueWith = 'Or continue with';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String hello = 'Hello';
  static const String healthSummary = 'Health Summary';
  static const String quickAccess = 'Quick Access';
  static const String aiHealthAssistant = 'AI Health Assistant';
  static const String fallDetection = 'Fall Detection';
  static const String medicineReminder = 'Medicine Reminder';
  static const String emergencyContacts = 'Emergency Contacts';
  static const String healthRecords = 'Health Records';
  static const String viewAll = 'View All';
  static const String sosEmergency = 'SOS Emergency';

  // AI Health Assistant
  static const String healthAssistant = 'Health Assistant';
  static const String describeSymptoms = 'Describe your symptoms...';
  static const String typeMessage = 'Type a message...';
  static const String aiThinking = 'Analyzing your symptoms...';
  static const String healthGuidance = 'Health Guidance';
  static const String emergencyDetected = '⚠️ Emergency Detected';
  static const String seekImmediateHelp = 'Please seek immediate medical attention!';
  static const String offlineFallback = 'You are offline. Using basic health guidance.';
  static const String clearChat = 'Clear Chat';

  // AI Health Assistant — Phase 5A
  static const String healthAssistantWelcome = 'Hi, I\'m your AI Health Assistant. I can offer general health and first-aid guidance, and if you tell me your symptoms I can suggest common non-prescription (OTC) medicine options with precautions. I\'m not a doctor and can\'t diagnose conditions or prescribe prescription-only medication. If you\'re experiencing a medical emergency, call emergency services right away. How can I help?';
  static const String healthAssistantDisclaimer = 'For emergencies, call your local emergency number. This assistant provides general guidance only and is not a substitute for professional medical care.';
  static const String healthAssistantSend = 'Send';
  static const String healthAssistantResponding = 'Responding…';
  static const String healthAssistantError = 'Something went wrong. Please try again.';
  static const String healthAssistantSendFailed = 'Not delivered';
  static const String healthAssistantSosPrompt = 'Your symptoms may be serious. Consider opening the emergency SOS to alert your trusted contacts.';
  static const String openEmergencySos = 'Open Emergency SOS';
  static const String healthAssistantClearConfirm = 'Clear the entire conversation?';

  // Emergency SOS
  static const String sosTitle = 'SOS Emergency';
  static const String sosDescription = 'Press the button below to send an emergency alert to your trusted contacts with your live location.';
  static const String sendSOS = 'Send SOS Alert';
  static const String sosSent = '🚨 SOS Alert Sent!';
  static const String contactsNotified = 'Your emergency contacts have been notified.';
  static const String locationShared = 'Your live location is being shared.';
  static const String cancelSOS = 'Cancel SOS';
  static const String callingEmergency = 'Calling emergency services...';

  // Emergency SOS — Phase 3A (core workflow)
  static const String sosIdle = 'Ready when you are';
  static const String sosIdleDescription = 'Press the SOS button to start the 5-second countdown. You can cancel at any time.';
  static const String sosCountdown = 'Sending in';
  static const String sosGettingLocation = 'Getting your location...';
  static const String sosLoadingContacts = 'Loading emergency contacts...';
  static const String sosPreparing = 'Preparing emergency event...';
  static const String sosReady = 'Emergency event ready';
  static const String sosCancelled = 'SOS cancelled';
  static const String sosNoContacts = 'No emergency contacts found';
  static const String sosNoContactsMessage = 'Add emergency contacts before using SOS. Your location was not shared and no alert was sent.';
  static const String sosFailed = 'SOS could not be completed';
  static const String sosLocationError = 'Unable to get your location. Please try again.';
  static const String sosContactsError = 'Could not load your emergency contacts. Please try again.';
  static const String sosEventError = 'Could not prepare the emergency event. Please try again.';
  static const String sosEventPrepared = 'Your emergency event is ready. Delivery to your contacts will be available in the next update.';
  static const String sosLocationStatus = 'Location';
  static const String sosLocationNotRequested = 'Not requested';
  static const String sosLocationAcquired = 'Acquired';
  static const String sosContactAvailability = 'Emergency contacts';
  static const String sosOpenLocation = 'Open in Maps';
  static const String sosAddContacts = 'Add Emergency Contacts';
  static const String sosTryAgain = 'Try Again';
  static const String sosStartNew = 'Start New SOS';
  static const String openSettings = 'Open Settings';
  static const String sosSending = 'Sending emergency alert...';
  static const String sosSentSuccessfully = 'Emergency alert sent successfully.';
  static const String sosPartiallySent = 'Emergency alert partially delivered.';
  static const String sosDeliveryFailed = 'Emergency alert delivery failed.';
  static const String sosAlreadyDelivered = 'Emergency alert was already delivered.';
  static const String sosDeliveryInProgress = 'Emergency alert delivery is already in progress.';

  // Emergency SOS — Phase 4A (history)
  static const String sosHistoryTitle = 'SOS History';
  static const String sosHistoryEmpty = 'No SOS events yet';
  static const String sosHistoryEmptyDescription = 'Your past SOS events will appear here after you use the SOS button.';
  static const String sosHistoryLoadError = 'Could not load your SOS history. Please try again.';
  static const String sosHistoryRetry = 'Retry';
  static const String sosHistoryEventStatus = 'Event status';
  static const String sosHistoryDeliveryStatus = 'Delivery status';
  static const String sosHistoryLocation = 'Location';
  static const String sosHistoryLocationAvailable = 'Available';
  static const String sosHistoryLocationUnavailable = 'Not available';
  static const String sosHistoryTimeUnavailable = 'Time unavailable';
  static const String sosHistorySuccessful = 'Successful';
  static const String sosHistoryFailed = 'Failed';
  static const String sosHistoryContacts = 'Contacts';
  static const String sosHistoryDetail = 'View details';

  // Emergency SOS — Phase 4B (event detail)
  static const String sosHistoryDetailTitle = 'Event Details';
  static const String sosHistoryDetailEventTime = 'Event time';
  static const String sosHistoryDetailStatus = 'Status';
  static const String sosHistoryDetailDelivery = 'Delivery';
  static const String sosHistoryDetailDeliveryError = 'Delivery error';
  static const String sosHistoryDetailNoDeliveryData = 'No delivery data available.';
  static const String sosHistoryDetailLocation = 'Location';
  static const String sosHistoryDetailCoordinates = 'Coordinates';
  static const String sosHistoryDetailOpenMaps = 'Open in Google Maps';
  static const String sosHistoryDetailMapsError = 'Could not open Google Maps.';
  static const String sosHistoryDetailEventId = 'Event ID';

  // Fall Detection
  static const String fallDetected = '⚠️ Fall Detected!';
  static const String fallConfirmMessage = 'Are you okay? Tap "I\'m OK" if you\'re fine, or the alert will be sent automatically.';
  static const String imOk = "I'm OK";
  static const String sendingAlert = 'Sending alert to emergency contacts...';
  static const String sensorMonitoring = 'Sensor Monitoring';
  static const String fallDetectionActive = 'Fall Detection Active';
  static const String fallDetectionInactive = 'Fall Detection Inactive';
  static const String cooldownActive = 'Cooldown Active';

  // Medicine Reminder
  static const String addMedicine = 'Add Medicine';
  static const String medicineName = 'Medicine Name';
  static const String dosage = 'Dosage';
  static const String frequency = 'Frequency';
  static const String reminderTime = 'Reminder Time';
  static const String saveMedicine = 'Save Medicine';
  static const String myMedicines = 'My Medicines';
  static const String noMedicines = 'No medicines added yet.';
  static const String takeMedicine = 'Take Medicine';
  static const String medicineTaken = 'Marked as Taken';
  static const String medicineSkipped = 'Skipped';
  static const String medicationHistory = 'Medication History';

  // Emergency Contacts
  static const String addContact = 'Add Contact';
  static const String editContact = 'Edit Contact';
  static const String deleteContact = 'Delete Contact';
  static const String contactName = 'Contact Name';
  static const String contactPhone = 'Phone Number';
  static const String relationship = 'Relationship';
  static const String saveContact = 'Save Contact';
  static const String noContacts = 'No emergency contacts added yet.';
  static const String noContactsDescription = 'Add trusted contacts so they can be alerted in an emergency.';
  static const String callNow = 'Call Now';
  static const String sendMessage = 'Send Message';
  static const String primaryContact = 'Primary Contact';
  static const String setAsPrimary = 'Set as Primary';
  static const String primaryContactDescription = 'This contact will be alerted first in an emergency.';
  static const String deleteContactConfirmTitle = 'Delete Contact';
  static const String deleteContactConfirmMessage = 'Are you sure you want to delete this contact?';
  static const String contactAdded = 'Contact added successfully';
  static const String contactUpdated = 'Contact updated successfully';
  static const String contactDeleted = 'Contact deleted successfully';
  static const String primaryContactUpdated = 'Primary contact updated';
  static const String relationshipSpouse = 'Spouse';
  static const String relationshipParent = 'Parent';
  static const String relationshipChild = 'Child';
  static const String relationshipSibling = 'Sibling';
  static const String relationshipFriend = 'Friend';
  static const String relationshipDoctor = 'Doctor';
  static const String relationshipOther = 'Other';

  // Profile
  static const String profile = 'Profile';
  static const String editProfile = 'Edit Profile';
  static const String updateProfile = 'Update Profile';
  static const String personalInfo = 'Personal Information';
  static const String medicalInfo = 'Medical Information';
  static const String bloodType = 'Blood Type';
  static const String allergies = 'Allergies';
  static const String medicalConditions = 'Medical Conditions';
  static const String emergencyInstructions = 'Emergency Instructions';
  static const String saveChanges = 'Save Changes';

  // Offline Mode
  static const String offlineMode = 'Offline Mode';
  static const String youAreOffline = 'You are currently offline';
  static const String offlineDescription = 'Some features may be limited. Emergency contacts and basic health guidance are available.';
  static const String emergencyInstructionsTitle = 'Emergency Instructions';
  static const String callEmergencyServices = 'Call Emergency Services';
  static const String findNearestHospital = 'Find Nearest Hospital';
  static const String basicFirstAid = 'Basic First Aid';
  static const String cprInstructions = 'CPR Instructions';
  static const String heimlichManeuver = 'Heimlich Maneuver';

  // General
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String noInternet = 'No internet connection';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String permissionsRequired = 'Permissions Required';
  static const String grantPermissions = 'Grant Permissions';
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String about = 'About';
  static const String version = 'Version';
  static const String help = 'Help';
  static const String faq = 'FAQ';
  static const String contactUs = 'Contact Us';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
}

