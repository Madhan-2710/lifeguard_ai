import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants/firebase_constants.dart';
import '../../features/medicine/domain/entities/medicine.dart';

/// Schedules local medicine reminders using `flutter_local_notifications`.
///
/// Reminders are scheduled per medicine per reminder time. The notification
/// body only repeats the user/doctor-entered dosage text — this app never
/// invents dosages or prescribes medication.
class MedicineReminderService {
  MedicineReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Initializes the plugin and the timezone database. Safe to call multiple
  /// times; only the first call performs work.
  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Schedules one repeating daily reminder per reminder time for [medicine].
  ///
  /// Notification ids are derived deterministically from the medicine id and
  /// the time slot so that re-saving a medicine reschedules the same slots.
  Future<void> scheduleMedicineReminders(Medicine medicine) async {
    await initialize();
    if (!medicine.isActive) {
      await cancelMedicineReminders(medicine.id);
      return;
    }

    final times = medicine.reminderTimes;
    if (times.isEmpty) return;

    // On Android 12+ exact alarms require the SCHEDULE_EXACT_ALARM permission.
    // On Android 14+ it is denied by default for new installs, so fall back to
    // inexact scheduling when the permission is not granted instead of failing.
    final exactAllowed = await _canScheduleExactAlarms();
    final scheduleMode = exactAllowed
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    for (var i = 0; i < times.length; i++) {
      final time = times[i];
      final id = _notificationId(medicine.id, i);
      final scheduled = _nextInstanceOf(time.hour, time.minute);

      await _plugin.zonedSchedule(
        id,
        medicine.name,
        _reminderBody(medicine),
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            FirebaseConstants.medicineChannelId,
            FirebaseConstants.medicineChannelName,
            channelDescription: FirebaseConstants.medicineChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medicine.id,
      );
    }
  }

  /// Whether exact alarms can be scheduled on this device.
  ///
  /// Returns true on non-Android platforms and on Android < 12, where the
  /// permission does not exist. On Android 12+ it reflects the
  /// SCHEDULE_EXACT_ALARM permission state.
  Future<bool> _canScheduleExactAlarms() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();
    if (android == null) return true;
    return (await android.canScheduleExactNotifications()) ?? false;
  }

  /// Cancels all scheduled reminders for [medicineId].
  Future<void> cancelMedicineReminders(String medicineId) async {
    await initialize();
    // Cancel a generous fixed set of slots (matches the max reminder times
    // the UI allows, currently 4).
    for (var i = 0; i < 4; i++) {
      await _plugin.cancel(_notificationId(medicineId, i));
    }
  }

  /// Cancels every scheduled medicine reminder (e.g. on logout).
  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }

  String _reminderBody(Medicine medicine) {
    final parts = <String>[
      if (medicine.dosage.isNotEmpty) medicine.dosage,
      if (medicine.frequency.isNotEmpty) medicine.frequency,
    ];
    return parts.isEmpty
        ? 'Time to take your medicine'
        : 'Time to take your medicine — ${parts.join(' · ')}';
  }

  /// The next [hour]:[minute] occurrence, in the local timezone.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notificationId(String medicineId, int slot) {
    return medicineId.hashCode.abs() + slot;
  }
}
