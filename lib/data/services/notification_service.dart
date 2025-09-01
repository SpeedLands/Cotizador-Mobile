import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../utils/logger.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<NotificationService> init() async {
    await _configureLocalNotifications();
    await _configureFirebaseMessaging();
    tz.initializeTimeZones();
    logger.i('Servicio de Notificaciones inicializado.');
    return this;
  }

  Future<void> _configureLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);
  }

  Future<void> _configureFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Notificación Push recibida en primer plano.');
      _showLocalNotification(message);
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'Notificaciones de alta importancia',
          channelDescription:
              'Este canal se usa para notificaciones importantes.',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      payload: message.data['action_url'] as String?,
    );
  }

  Future<void> scheduleQuoteReminder(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
  ) async {
    // --- VALIDACIÓN DE FECHA FUTURA ---
    if (scheduledDate.isBefore(DateTime.now())) {
      logger.w(
        'No se programó la notificación ID:$id porque la fecha está en el pasado: $scheduledDate',
      );
      return; // No hacer nada si la fecha ya pasó
    }
    // --------------------------------

    await _localNotifications.zonedSchedule(
      id, // Usa un ID único por cotización para poder cancelarla si es necesario
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'quote_reminders_channel',
          'Recordatorios de Cotizaciones',
          channelDescription: 'Recordatorios para cotizaciones programadas.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    logger.i('Recordatorio de cotización programado para: $scheduledDate');
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    logger.i('Suscrito al topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    logger.i('Desuscrito del topic: $topic');
  }

  /// Cancela una notificación programada por su ID.
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    logger.i('Notificación con ID:$id cancelada.');
  }
}
