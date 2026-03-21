import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/course.dart';
import '../models/assignment.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS, require user's permission
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> scheduleAssignmentReminder(Assignment assignment) async {
    // Remind 1 day before due date
    final reminderTime = assignment.dueDate.subtract(const Duration(days: 1));
    if (reminderTime.isBefore(DateTime.now()))
      return; // Don't schedule if in past

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      assignment.id.hashCode,
      'Assignment Due Soon',
      '${assignment.title} is due tomorrow!',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'assignment_channel',
          'Assignment Reminders',
          channelDescription: 'Reminders for upcoming assignments',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Removed: uiLocalNotificationDateInterpretation – no longer exists / needed
    );
  }

  Future<void> cancelReminder(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleClassReminder(Course course) async {
    // Schedule weekly reminder 15 minutes before class
    final now = DateTime.now();

    // Find next occurrence of the class day of week
    int daysUntilClass = (course.dayOfWeek - now.weekday) % 7;
    if (daysUntilClass < 0) daysUntilClass += 7;

    DateTime nextClassDate = DateTime(
      now.year,
      now.month,
      now.day + daysUntilClass,
      course.time.hour,
      course.time.minute,
    );

    // If it's today but the time has passed, schedule for next week
    if (daysUntilClass == 0 && nextClassDate.isBefore(now)) {
      nextClassDate = nextClassDate.add(const Duration(days: 7));
    }

    final reminderTime = nextClassDate.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(now)) return;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      course.id.hashCode,
      'Class Starting Soon',
      '${course.name} starts in 15 minutes',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_channel',
          'Class Reminders',
          channelDescription: 'Reminders for upcoming classes',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // Weekly reminder
      // Removed: uiLocalNotificationDateInterpretation – no longer exists / needed
    );
  }
}
