import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/models/notification_model.dart';
import '../../data/services/api_service.dart';
import '../../utils/logger.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = true.obs;
  var notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Envoltura genérica para llamadas a la API.
  /// Retorna `true` si la llamada fue exitosa, `false` si no.
  Future<bool> _callApi(
    Future<void> Function() apiCall, {
    String? successMessage,
    bool showLoading = false,
  }) async {
    if (showLoading) {
      isLoading.value = true;
    }
    try {
      await apiCall();
      if (successMessage != null) {
        Get.snackbar(
          'Éxito',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } on DioException catch (e) {
      String errorMessage = 'Error de red desconocido.';
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['message'] as String? ??
            'El servidor no proporcionó un mensaje de error.';
      } else if (responseData != null) {
        errorMessage = responseData.toString();
      }
      Get.snackbar(
        'Error de API',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      logger.e('Error de Dio en NotificationController', error: e);
      return false;
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      logger.e('Error inesperado en NotificationController', error: e);
      return false;
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  /// Obtiene las notificaciones desde la API.
  Future<void> fetchNotifications() async {
    await _callApi(() async {
      notifications.clear();
      final result = await _apiService.getNotifications();
      notifications.assignAll(result);
    }, showLoading: true);
  }

  /// Marca una notificación como leída con UI optimista y rollback en caso de error.
  Future<void> markAsRead(int notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) {
      return;
    }

    // UI Optimista: actualiza la UI inmediatamente
    final originalNotification = notifications[index];
    notifications[index] = originalNotification.copyWith(isRead: true);

    final success = await _callApi(() async {
      await _apiService.markNotificationAsRead(notificationId);
    });

    // Rollback: si la API falla, revierte el cambio en la UI
    if (!success) {
      notifications[index] = originalNotification;
      Get.snackbar('Error', 'No se pudo actualizar la notificación.');
    }
  }

  /// Elimina una notificación.
  Future<void> deleteNotification(int notificationId) async {
    await _callApi(() async {
      await _apiService.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
    }, successMessage: 'Notificación eliminada.');
  }

  /// Maneja la acción de una URL de notificación.
  void handleActionUrl(String actionUrl) {
    if (actionUrl.isEmpty) {
      return;
    }

    // Normaliza la ruta si es necesario
    final String route = actionUrl.startsWith('/cotizaciones/')
        ? actionUrl.replaceFirst('/cotizaciones/', '/cotizacion/')
        : actionUrl;

    // Navega si la ruta es reconocida
    if (route.startsWith('/cotizacion/')) {
      Get.toNamed(route);
    } else {
      logger.w('Formato de action_url no reconocido', error: actionUrl);
      Get.snackbar(
        'Acción no disponible',
        'Este tipo de notificación no se puede abrir.',
      );
    }
  }
}
