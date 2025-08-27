import 'dart:ffi';

import 'package:dio/dio.dart';

import '../../utils/logger.dart';
import '../models/calendario_evento_model.dart';
import '../models/cotizacion_model.dart';
import '../models/dashboard_data_model.dart';
import '../models/notification_model.dart';
import '../models/servicio_model.dart';
import '../providers/dio_client.dart';

class ApiService {
  final Dio _dio = DioClient().dio;

  Future<T> _requestWrapper<T>(
    String method,
    String path, {
    Object? data,
    dynamic Function(Map<String, dynamic> json)? fromJson,
    String? operationName,
  }) async {
    final opName = operationName ?? '${method.toUpperCase()} $path';
    logger.i('Iniciando: $opName...');

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        options: Options(method: method),
      );

      logger.i('✅ Éxito: $opName');

      final responseData = response.data;

      // --- INICIO DE LA SECCIÓN MODIFICADA ---
      if (fromJson != null) {
        if (responseData is List) {
          // Determinar el tipo de la lista esperada y mapear
          if (T == List<Servicio>) {
            return responseData
                    .map(
                      (item) =>
                          fromJson(item as Map<String, dynamic>) as Servicio,
                    )
                    .toList()
                as T;
          } else if (T == List<Cotizacion>) {
            return responseData
                    .map(
                      (item) =>
                          fromJson(item as Map<String, dynamic>) as Cotizacion,
                    )
                    .toList()
                as T;
          } else if (T == List<CalendarioEvento>) {
            return responseData
                    .map(
                      (item) =>
                          fromJson(item as Map<String, dynamic>)
                              as CalendarioEvento,
                    )
                    .toList()
                as T;
          } else if (T == List<AppNotification>) {
            return responseData
                    .map(
                      (item) =>
                          fromJson(item as Map<String, dynamic>)
                              as AppNotification,
                    )
                    .toList()
                as T;
          }
          // Puedes añadir más `else if` para otros tipos de listas que manejes.
          // Si no se encuentra un tipo específico, intenta un cast genérico
          // que podría fallar si el fromJson no es lo suficientemente fuerte.
          // Es mejor tener cada tipo explícito si la inferencia de Dart falla.
          else {
            logger.w(
              'Tipo de lista no manejado explícitamente: $T. Intentando cast genérico.',
            );
            return responseData
                    .map((item) => fromJson(item as Map<String, dynamic>))
                    .toList()
                as T;
          }
        } else {
          // Si no es una lista, mapea el objeto singular
          return fromJson(responseData as Map<String, dynamic>) as T;
        }
      }
      // --- FIN DE LA SECCIÓN MODIFICADA ---

      if (T == Void) {
        return null as T;
      }
      if (responseData is List && T == List<String>) {
        return List<String>.from(responseData) as T;
      }

      return responseData as T;
    } on DioException catch (e, stackTrace) {
      logger.e('Error de API en: $opName', error: e, stackTrace: stackTrace);
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        logger.w('Error de validación:', error: e.response?.data);
      }
      rethrow;
    } catch (e, stackTrace) {
      logger.f(
        'Error inesperado en: $opName. ¿Formato JSON correcto?',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) =>
      _requestWrapper(
        'POST',
        '/auth/login',
        data: {'email': email, 'password': password},
        operationName: 'Login para $email',
      );

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) => _requestWrapper(
    'POST',
    '/auth/register',
    data: {'name': name, 'email': email, 'password': password},
    operationName: 'Registro para $email',
  );

  // Servicios
  Future<List<Servicio>> getServicios() => _requestWrapper<List<Servicio>>(
    'GET',
    '/servicios',
    fromJson: Servicio.fromJson,
    operationName: 'Obtener lista de servicios',
  );

  Future<Servicio> getServicioById(int id) => _requestWrapper<Servicio>(
    'GET',
    '/servicios/$id',
    fromJson: Servicio.fromJson,
    operationName: 'Obtener servicio ID: $id',
  );

  Future<Servicio> createServicio(Map<String, dynamic> data) =>
      _requestWrapper<Servicio>(
        'POST',
        '/admin/servicios',
        data: data,
        fromJson: (json) =>
            Servicio.fromJson(json['servicio'] as Map<String, dynamic>),
        operationName: 'Crear servicio: ${data['nombre']}',
      );

  Future<Servicio> updateServicio(int id, Map<String, dynamic> data) =>
      _requestWrapper<Servicio>(
        'PUT',
        '/admin/servicios/$id',
        data: data,
        fromJson: (json) =>
            Servicio.fromJson(json['servicio'] as Map<String, dynamic>),
        operationName: 'Actualizar servicio ID: $id',
      );

  Future<void> deleteServicio(int id) => _requestWrapper<void>(
    'DELETE',
    '/admin/servicios/$id',
    operationName: 'Eliminar servicio ID: $id',
  );

  // Cotizaciones
  Future<Map<String, dynamic>> createCotizacion(Map<String, dynamic> data) =>
      _requestWrapper(
        'POST',
        '/cotizaciones',
        data: data,
        operationName: 'Crear cotización para ${data['nombre_completo']}',
      );

  Future<Cotizacion> getCotizacionById(int id, {bool isAdmin = false}) =>
      _requestWrapper<Cotizacion>(
        'GET',
        isAdmin ? '/admin/cotizaciones/$id' : '/cotizaciones/$id',
        fromJson: Cotizacion.fromJson,
        operationName: 'Obtener cotización ID: $id',
      );

  Future<List<Cotizacion>> getAllCotizaciones() =>
      _requestWrapper<List<Cotizacion>>(
        'GET',
        '/admin/cotizaciones',
        fromJson: Cotizacion.fromJson,
        operationName: 'Obtener todas las cotizaciones',
      );

  Future<void> updateCotizacion(
    int id,
    Map<String, dynamic> data, {
    bool isAdmin = false,
  }) => _requestWrapper<void>(
    'PUT',
    isAdmin ? '/admin/cotizaciones/$id' : '/cotizaciones/$id',
    data: data,
    operationName: 'Actualizar cotización ID: $id',
  );

  Future<void> deleteCotizacion(int id) => _requestWrapper<void>(
    'DELETE',
    '/admin/cotizaciones/$id',
    operationName: 'Eliminar cotización ID: $id',
  );

  // Calendario
  Future<List<String>> getFechasOcupadas() => _requestWrapper<List<String>>(
    'GET',
    '/calendario/fechas-ocupadas',
    operationName: 'Obtener fechas ocupadas',
  );

  Future<List<CalendarioEvento>> getCalendarioEventos() =>
      _requestWrapper<List<CalendarioEvento>>(
        'GET',
        '/admin/calendario/eventos',
        fromJson: CalendarioEvento.fromJson,
        operationName: 'Obtener eventos del calendario (Admin)',
      );

  // Dashboard
  Future<DashboardData> getDashboardData() => _requestWrapper<DashboardData>(
    'GET',
    '/admin/dashboard',
    fromJson: DashboardData.fromJson,
    operationName: 'Obtener datos del dashboard (Admin)',
  );

  // Notificaciones
  Future<List<AppNotification>> getNotifications() =>
      _requestWrapper<List<AppNotification>>(
        'GET',
        '/admin/notifications',
        fromJson: AppNotification.fromJson,
        operationName: 'Obtener notificaciones (Admin)',
      );

  Future<void> markNotificationAsRead(int id) => _requestWrapper<void>(
    'PUT',
    '/admin/notifications/$id',
    operationName: 'Marcar notificación como leída ID: $id',
  );

  Future<void> deleteNotification(int id) => _requestWrapper<void>(
    'DELETE',
    '/admin/notifications/$id',
    operationName: 'Eliminar notificación ID: $id',
  );
}
