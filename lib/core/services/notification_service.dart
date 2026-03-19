import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Future<void> init() async {
    if (kIsWeb) return;
    // Notifications work on Android/iOS only
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
  }
}