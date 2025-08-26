import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/api_service.dart';
import '../../utils/logger.dart';

class NotificationController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      // Limpiamos la lista para el efecto de "refrescar"
      notifications.clear();
      final result = await _apiService.getNotifications();
      notifications.assignAll(result);
    } on Exception {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las notificaciones.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    // Buscamos la notificación en la lista
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) {
      // Si no se encuentra o ya está leída, no hacemos nada
      return;
    }

    try {
      await _apiService.markNotificationAsRead(notificationId);

      // Actualizamos el estado localmente para una respuesta instantánea en la UI
      final oldNotification = notifications[index];
      notifications[index] = AppNotification(
        id: oldNotification.id,
        title: oldNotification.title,
        body: oldNotification.body,
        isRead: true, // <-- El único cambio
        actionUrl: oldNotification.actionUrl,
        createdAt: oldNotification.createdAt,
      );
    } on Exception {
      // Si falla la llamada a la API, no hacemos cambios en la UI y mostramos un error.
      Get.snackbar('Error', 'No se pudo marcar la notificación como leída.');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      // Hacemos la llamada a la API primero
      await _apiService.deleteNotification(notificationId);

      // Si la llamada es exitosa, eliminamos la notificación de la lista local
      notifications.removeWhere((n) => n.id == notificationId);

      Get.snackbar(
        'Éxito',
        'Notificación eliminada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on Exception {
      Get.snackbar('Error', 'No se pudo eliminar la notificación.');
    }
  }

  void handleActionUrl(String actionUrl) {
    if (actionUrl.isEmpty) {
      // Si no hay URL, no hacemos nada.
      return;
    }

    String finalRoute = actionUrl;

    // --- LÓGICA DE NORMALIZACIÓN ---
    // Si la URL viene en el formato "incorrecto" (plural), la corregimos.
    if (actionUrl.startsWith('/cotizaciones/')) {
      finalRoute = actionUrl.replaceFirst('/cotizaciones/', '/cotizacion/');
    }

    // --- LÓGICA DE NAVEGACIÓN ---
    // Ahora que la ruta está normalizada, verificamos si es una ruta que conocemos.
    if (finalRoute.startsWith('/cotizacion/')) {
      Get.toNamed(finalRoute);
    }
    // Aquí podrías añadir más rutas en el futuro si las necesitas
    // else if (finalRoute.startsWith('/servicios/')) {
    //   Get.toNamed(finalRoute);
    // }
    else {
      // Si no reconocemos la URL, mostramos un mensaje en lugar de fallar.
      logger.w('Formato de action_url no reconocido', error: actionUrl);
      Get.snackbar(
        'Acción no disponible',
        'Este tipo de notificación no se puede abrir.',
      );
    }
  }
}
