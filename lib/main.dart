import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/custom_reminder_service.dart';
import 'data/services/notification_service.dart';
import 'firebase_options.dart';
import 'global/widgets/auth_wrapper.dart';
import 'modules/auth/auth_binding.dart';
import 'modules/auth/auth_controller.dart';
import 'routes/app_routes.dart';
import 'utils/logger.dart';

// --- TAREA DE FONDO ---
// Esta función debe estar fuera de cualquier clase (top-level)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Se necesita inicializar los servicios de nuevo en este isolate de fondo
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Crear AuthService primero
    final authService = AuthService();
    await authService.initialize();
    Get
      ..put(authService, permanent: true)
      ..put(ApiService(authService), permanent: true);
    await Get.putAsync(() => NotificationService().init());

    logger.i("Workmanager: Ejecutando tarea de fondo '$task'");

    try {
      final apiService = Get.find<ApiService>();
      final notificationService = Get.find<NotificationService>();
      final cotizaciones = await apiService.getAllCotizaciones();

      final now = DateTime.now();

      for (final cotizacion in cotizaciones) {
        try {
          final eventDate = DateTime.parse(cotizacion.fechaEvento);
          final difference = eventDate.difference(now).inDays;

          // Recordatorio de 7 días
          if (difference <= 7 && difference > 6) {
            await notificationService.scheduleQuoteReminder(
              cotizacion.id,
              'Recordatorio de Evento',
              'El evento para "${cotizacion.nombreCompleto}" es en una semana.',
              eventDate.subtract(const Duration(days: 7)),
            );
          }

          // Recordatorio de 1 día
          if (difference <= 1 && difference > 0) {
            await notificationService.scheduleQuoteReminder(
              cotizacion.id,
              '¡Evento Próximo!',
              'El evento para "${cotizacion.nombreCompleto}" es mañana.',
              eventDate.subtract(const Duration(days: 1)),
            );
          }
        } on Exception catch (e) {
          logger.e(
            'Workmanager: Error procesando cotización ID: ${cotizacion.id}',
            error: e,
          );
        }
      }
      logger.i('Workmanager: Tarea completada exitosamente.');
      return Future.value(true);
    } on Exception catch (e) {
      logger.e('Workmanager: Error durante la ejecución de la tarea', error: e);
      return Future.value(false);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Workmanager
  Workmanager().initialize(callbackDispatcher);
  // Registrar la tarea periódica
  Workmanager().registerPeriodicTask(
    '1', // ID único para la tarea
    'cotizacionReminderTask',
    frequency: const Duration(hours: 12), // Frecuencia de ejecución
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // Inicializar AuthService primero
  final authService = AuthService();
  await authService.initialize();

  // Determinar la ruta inicial basada en el estado de autenticación
  String initialRoute;
  if (authService.isAuthenticated()) {
    initialRoute = AppRoutes.DASHBOARD;
  } else {
    initialRoute = AppRoutes.COTIZADOR;
  }

  // Inicializar servicios con GetX
  Get
    ..put(authService, permanent: true)
    ..put(ApiService(authService), permanent: true);
  await Get.putAsync(
    () => NotificationService().init(),
  ); // Inicializar NotificationService
  await Get.putAsync(() => CustomReminderService().init());
  Get.put(AuthController(), permanent: true);

  runApp(
    AuthWrapper(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mapolato App',
        theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
        locale: const Locale('es', 'MX'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          PhoneFieldLocalization.delegate,
        ],
        supportedLocales: const [Locale('es', 'MX')],
        initialRoute: initialRoute,
        getPages: AppPages.routes,
        initialBinding: AuthBinding(),
      ),
    ),
  );
}
