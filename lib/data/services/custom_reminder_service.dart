import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_reminder_model.dart';
import 'notification_service.dart';

class CustomReminderService extends GetxService {
  late final SharedPreferences _prefs;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  static const _remindersKey = 'custom_reminders';

  Future<CustomReminderService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Obtiene todos los recordatorios del almacenamiento
  Future<List<CustomReminder>> _getAllReminders() async {
    final remindersJson = _prefs.getStringList(_remindersKey) ?? [];
    return remindersJson.map(CustomReminder.fromJson).toList();
  }

  // Guarda la lista completa de recordatorios
  Future<void> _saveAllReminders(List<CustomReminder> reminders) async {
    final remindersJson = reminders.map((r) => r.toJson()).toList();
    await _prefs.setStringList(_remindersKey, remindersJson);
  }

  /// Obtiene los recordatorios para una cotización específica
  Future<List<CustomReminder>> getRemindersForQuote(int quoteId) async {
    final allReminders = await _getAllReminders();
    return allReminders.where((r) => r.quoteId == quoteId).toList();
  }

  /// Guarda un nuevo recordatorio y programa la notificación
  Future<void> saveReminder(CustomReminder reminder) async {
    final allReminders = await _getAllReminders();
    allReminders.add(reminder);
    await _saveAllReminders(allReminders);

    // Programar la notificación
    await _notificationService.scheduleQuoteReminder(
      reminder.notificationId,
      reminder.title,
      reminder.body,
      reminder.scheduledDate,
    );
  }

  /// Elimina un recordatorio y cancela la notificación
  Future<void> deleteReminder(int notificationId) async {
    final allReminders = await _getAllReminders();
    allReminders.removeWhere((r) => r.notificationId == notificationId);
    await _saveAllReminders(allReminders);

    // Cancelar la notificación
    await _notificationService.cancelNotification(notificationId);
  }
}
