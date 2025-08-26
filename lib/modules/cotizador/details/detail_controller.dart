import 'package:get/get.dart';
import '../../../data/models/cotizacion_model.dart';
import '../../../data/services/api_service.dart';
import '../../auth/auth_controller.dart';

class DetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthController _authController = Get.find<AuthController>();

  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);
  var cotizacionActual = Rx<Cotizacion?>(null);

  Future<void> fetchCotizacionById(int id) async {
    await _handleApiCall(
      apiCall: () async {
        final bool isAdmin = _authController.isAuthenticated.value;
        final cotizacion = await _apiService.getCotizacionById(
          id,
          isAdmin: isAdmin,
        );
        cotizacionActual.value = cotizacion;
      },
      onError: (e) {
        Get.snackbar(
          'Error',
          'No se pudieron cargar los detalles de la cotización. \nError: ${e.toString()}',
        );
        cotizacionActual.value = null;
      },
    );
  }

  Future<void> updateCotizacionStatus(int id, String newStatus) async {
    await _handleApiCall(
      apiCall: () async {
        final bool isAdmin = _authController.isAuthenticated.value;
        final cotizacion = _buildCotizacionData(status: newStatus);
        await _apiService.updateCotizacion(id, cotizacion, isAdmin: isAdmin);
        return null;
      },
      onSuccess: (_) async {
        Get.snackbar(
          'Éxito',
          'El estado de la cotización ha sido actualizado.',
        );
        await fetchCotizacionById(id);
      },
      onError: (e) {
        Get.snackbar(
          'Error',
          'No se pudo actualizar el estado. ${e.toString()}',
        );
      },
    );
  }

  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    Function(T)? onSuccess,
    Function(dynamic)? onError,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await apiCall();
      if (onSuccess != null) {
        onSuccess(result);
      }
    } on Exception catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        Get.snackbar(
          'Error',
          'Ocurrió un error inesperado: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildCotizacionData({String? status}) {
    if (status != null) {
      if (cotizacionActual.value == null) {
        Get.snackbar(
          'Error',
          'Se intentó actualizar el estado sin una cotización cargada.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return {};
      }
      final List<int> serviciosIds =
          cotizacionActual.value?.serviciosSeleccionados
              ?.map((servicio) => servicio.id) // Extrae el id de cada servicio
              .toList() ?? // Conviértelo a una lista
          [];

      return {
        'nombre_completo': cotizacionActual.value?.nombreCompleto,
        'whatsapp': cotizacionActual.value?.whatsapp,
        'tipo_evento': cotizacionActual.value?.tipoEvento,
        'nombre_empresa': cotizacionActual.value?.nombreEmpresa,
        'direccion_evento': cotizacionActual.value?.direccionEvento,
        'fecha_evento': cotizacionActual
            .value
            ?.fechaEvento, // Asegúrate de que este tenga el formato 'YYYY-MM-DD'
        'hora_evento': cotizacionActual.value?.horaEvento,
        'horario_consumo': cotizacionActual.value?.horarioConsumo,

        // --- Datos de servicios ---
        'cantidad_invitados': cotizacionActual.value?.cantidadInvitados,
        'servicios': serviciosIds, // Convierte el Set<int> a una List<int>
        'servicios_otros': cotizacionActual.value?.serviciosOtros,

        // --- Detalles finales ---
        'como_supiste': cotizacionActual.value?.comoSupiste,
        'como_supiste_otro': cotizacionActual.value?.comoSupisteOtro,
        'mesa_mantel': cotizacionActual.value?.mesaMantel,
        'mesa_mantel_otro': cotizacionActual.value?.mesaMantelOtro,
        'personal_servicio': cotizacionActual.value?.personalServicio,
        'acceso_enchufe': cotizacionActual.value?.accesoEnchufe,
        'dificultad_montaje': cotizacionActual.value?.dificultadMontaje,
        'tipo_consumidores': cotizacionActual.value?.tipoConsumidores,
        'restricciones': cotizacionActual.value?.restricciones,
        'requisitos_adicionales': cotizacionActual.value?.requisitosAdicionales,
        'presupuesto': cotizacionActual.value?.presupuesto,
        'status': status,
        'guest_token': cotizacionActual.value?.guestToken,
        'fecha_creacion': cotizacionActual.value?.fechaCreacion,
        'total_base': cotizacionActual.value?.totalBase,
        'costo_adicional_ia': cotizacionActual.value?.costoAdicionalIa,
        'total_estimado': cotizacionActual.value?.totalEstimado,
        'justificacion_ia': cotizacionActual.value?.justificacionIa,
      };
    } else {
      return {};
    }
  }
}
