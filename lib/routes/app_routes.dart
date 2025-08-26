// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/auth/auth_binding.dart';
import '../modules/auth/login_screen.dart';
import '../modules/calendario/calendario_binding.dart';
import '../modules/calendario/calendario_screen.dart';
import '../modules/cotizador/cotizacion_binding.dart';
import '../modules/cotizador/cotizador_screen.dart';
import '../modules/cotizador/details/cotizacion_detail_screen.dart';
import '../modules/cotizador/details/detail_binding.dart';
import '../modules/cotizador/list/cotizaciones_list_screen.dart';
import '../modules/cotizador/list/list_binding.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/dashboard/dashboard_screen.dart';
import '../modules/notificaciones/notification_binding.dart';
import '../modules/notificaciones/notifications_screen.dart';
import '../modules/servicio/servicio_binding.dart';
import '../modules/servicio/servicio_form.dart';
import '../modules/servicio/servicio_screen.dart';

class AppRoutes {
  static const INITIAL = '/';
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const COTIZADOR = '/cotizador';
  static const COTIZACION_DETAIL = '/cotizacion/:id';
  static const COTIZACIONES_LIST = '/cotizaciones';
  static const SERVICES_LIST = '/services';
  static const SERVICIO_FORM = '/servicio/form';
  static const CALENDARIO = '/calendario';
  static const NOTIFICATIONS = '/notifications';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.COTIZADOR,
      page: CotizadorScreen.new,
      binding: CotizacionBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: LoginScreen.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: DashboardScreen.new,
      bindings: [DashboardBinding(), AuthBinding()],
    ),
    GetPage(
      name: AppRoutes.COTIZACIONES_LIST,
      page: CotizacionesListScreen.new,
      bindings: [CotizacionBinding(), AuthBinding(), ListBinding()],
    ),
    GetPage(
      name: AppRoutes.COTIZACION_DETAIL,
      page: CotizacionDetailScreen.new,
      bindings: [CotizacionBinding(), AuthBinding(), DetailBinding()],
    ),
    GetPage(
      name: AppRoutes.SERVICES_LIST,
      page: ServiciosListScreen.new,
      bindings: [AuthBinding(), ServicioBinding()],
    ),
    GetPage(
      name: AppRoutes.SERVICIO_FORM,
      page: ServicioFormScreen.new,
      bindings: [AuthBinding(), ServicioBinding()],
    ),
    GetPage(
      name: AppRoutes.CALENDARIO,
      page: CalendarioScreen.new,
      bindings: [CalendarioBinding(), AuthBinding()],
    ),
    GetPage(
      name: AppRoutes.NOTIFICATIONS,
      page: NotificationsScreen.new,
      bindings: [NotificationBinding(), AuthBinding()],
    ),
  ];
}
