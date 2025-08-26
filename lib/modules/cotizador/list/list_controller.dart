import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../data/models/cotizacion_model.dart';
import '../../../data/services/api_service.dart';

class ListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final searchQueryController = TextEditingController();
  var searchQuery = ''.obs;
  var selectedStatus = 'Todos'.obs;
  var selectedEventType = 'Todos'.obs;
  var startDate = Rx<DateTime?>(null);
  var endDate = Rx<DateTime?>(null);
  var _allCotizaciones = <Cotizacion>[];
  var cotizacionesList = <Cotizacion>[].obs;

  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);

  void filterCotizaciones() {
    final query = searchQuery.value.toLowerCase();

    var filteredList = List<Cotizacion>.from(_allCotizaciones);

    if (query.isNotEmpty) {
      filteredList = filteredList
          .where(
            (cotizacion) =>
                cotizacion.nombreCompleto.toLowerCase().contains(query),
          )
          .toList();
    }

    if (selectedStatus.value != 'Todos') {
      filteredList = filteredList
          .where(
            (cotizacion) =>
                cotizacion.status.toLowerCase() ==
                selectedStatus.value.toLowerCase(),
          )
          .toList();
    }

    if (selectedEventType.value != 'Todos') {
      filteredList = filteredList
          .where((c) => c.tipoEvento == selectedEventType.value)
          .toList();
    }

    if (startDate.value != null && endDate.value != null) {
      filteredList = filteredList.where((c) {
        try {
          // Asumimos que la fecha viene en formato 'YYYY-MM-DD'
          final eventDate = DateTime.parse(c.fechaEvento);
          return eventDate.isAfter(startDate.value!) &&
              eventDate.isBefore(endDate.value!);
        } on Exception {
          // Si el formato de fecha es incorrecto, no lo incluye en el filtro
          return false;
        }
      }).toList();
    }

    cotizacionesList.value = filteredList;
  }

  void changeStatusFilter(String? newStatus) {
    if (newStatus != null) {
      selectedStatus.value = newStatus;
      filterCotizaciones();
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    // Añadimos un día al final para que la búsqueda incluya el último día seleccionado
    endDate.value = DateTime(end.year, end.month, end.day, 23, 59, 59);
  }

  void clearFilters() {
    selectedStatus.value = 'Todos';
    selectedEventType.value = 'Todos';
    startDate.value = null;
    endDate.value = null;
    filterCotizaciones(); // Vuelve a filtrar para mostrar todo
  }

  Future<void> fetchAllCotizaciones() async {
    await _handleApiCall(
      apicall: () async {
        final cotizaciones = await _apiService.getAllCotizaciones();
        _allCotizaciones = cotizaciones;
        filterCotizaciones();
        return null;
      },
      onError: (e) {
        Get.snackbar(
          'Error',
          'No se pudo obtener la lista de cotizaciones. ${e.toString()}',
        );
      },
    );
  }

  Future<void> deleteCotizacion(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _apiService.deleteCotizacion(id);

      cotizacionesList.removeWhere((cotizacion) => cotizacion.id == id);

      Get.snackbar('Éxito', 'La cotización #$id ha sido eliminada.');
    } on Exception {
      errorMessage.value = 'No se pudo eliminar la cotización.';
      Get.snackbar('Error', errorMessage.value!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleApiCall<T>({
    required Future<T> Function() apicall,
    Function(T)? onSuccess,
    Function(dynamic)? onError,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await apicall();
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
}
