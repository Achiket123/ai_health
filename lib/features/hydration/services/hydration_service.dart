import 'package:ai_health/services/system_notification_service.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:async';
import 'dart:developer' as developer;

class HydrationService {
  static const int _reminderAlarmId = 12345;

  // Initialize hydration service
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  // Setup daily hydration reminders
  static Future<void> setupDailyReminders({
    required int intervalMinutes,
    required int glassesPerDay,
  }) async {
    try {
      // Cancel existing alarms
      await AndroidAlarmManager.cancel(_reminderAlarmId);

      // Generate reminder times for the day
      final reminderTimes = _generateReminderTimes(intervalMinutes);

      // Schedule first reminder
      if (reminderTimes.isNotEmpty) {
        await _scheduleReminder(
          reminderTimes.first,
          intervalMinutes,
          glassesPerDay,
        );
      }
    } catch (e) {
      developer.log('Error setting up reminders: $e', error: e);
    }
  }

  // Schedule a single reminder
  static Future<void> _scheduleReminder(
    DateTime reminderTime,
    int intervalMinutes,
    int glassesPerDay,
  ) async {
    final now = DateTime.now();
    final duration = reminderTime.difference(now);

    if (duration.isNegative) {
      // Time has passed, calculate next day
      final nextDayTime = reminderTime.add(const Duration(days: 1));
      return _scheduleReminder(
        nextDayTime,
        intervalMinutes,
        glassesPerDay,
      );
    }

    try {
      await AndroidAlarmManager.oneShotAt(
        reminderTime,
        _reminderAlarmId,
        _reminderCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      // Schedule next reminder
      final nextReminderTime = reminderTime.add(
        Duration(minutes: intervalMinutes),
      );

      // Check if next reminder is still within the same day
      if (nextReminderTime.day == reminderTime.day &&
          nextReminderTime.hour < 23) {
        // Schedule next reminder for same day
        Future.delayed(duration, () {
          _scheduleReminder(
            nextReminderTime,
            intervalMinutes,
            glassesPerDay,
          );
        });
      } else {
        // Schedule for next day
        final nextDay = DateTime(
          reminderTime.year,
          reminderTime.month,
          reminderTime.day + 1,
          reminderTime.hour,
          reminderTime.minute,
        );
        Future.delayed(duration, () {
          _scheduleReminder(
            nextDay,
            intervalMinutes,
            glassesPerDay,
          );
        });
      }
    } catch (e) {
      developer.log('Error scheduling reminder: $e', error: e);
    }
  }

  // Callback function for alarm (must be static/top-level)
  @pragma('vm:entry-point')
  static Future<void> _reminderCallback() async {
    // Initialize notification service in this isolate
    final notificationService = SystemNotificationService();
    await notificationService.initialize();
    
    await notificationService.showNotification(
      id: _reminderAlarmId,
      title: 'Hydration Time',
      body: 'Time to drink water! Stay hydrated! 💧',
    );
  }

  // Generate reminder times for the day
  static List<DateTime> _generateReminderTimes(int intervalMinutes) {
    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
      6,
      0,
    ); // Start from 6 AM
    final endTime = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
    ); // End at 11:59 PM

    final times = <DateTime>[];
    var currentTime = startTime;

    while (currentTime.isBefore(endTime)) {
      if (currentTime.isAfter(now)) {
        times.add(currentTime);
      }
      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
    }

    return times;
  }

  // Cancel all reminders
  static Future<void> cancelReminders() async {
    try {
      await AndroidAlarmManager.cancel(_reminderAlarmId);
    } catch (e) {
      developer.log('Error canceling reminders: $e', error: e);
    }
  }

  // Get daily water target in glasses
  static int getDailyTarget() {
    return 8; // 8 glasses per day (standard recommendation)
  }

  // Calculate glasses per interval
  static int getGlassesPerInterval(int intervalMinutes) {
    final dailyTarget = getDailyTarget();
    final intervalsPerDay = (24 * 60) ~/ intervalMinutes;
    return (dailyTarget / intervalsPerDay).ceil();
  }

  // Pause reminders (stop scheduling new ones)
  static Future<void> pauseReminders() async {
    await cancelReminders();
  }

  // Resume reminders
  static Future<void> resumeReminders({
    required int intervalMinutes,
  }) async {
    final glassesPerDay = getDailyTarget();
    await setupDailyReminders(
      intervalMinutes: intervalMinutes,
      glassesPerDay: glassesPerDay,
    );
  }
}
