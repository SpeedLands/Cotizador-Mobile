import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/servicio_model.dart';
import '../../data/services/api_service.dart';

class ServicioController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var _allServicios = <Servicio>[];
  var servicios = <Servicio>[].obs;
  final searchQueryController = TextEditingController();
  var searchQuery = ''.obs;
  var selectedTipoCobro = 'Todos'.obs;

  @override
  void onInit() {
    super.onInit();
    searchQueryController.addListener(() {
      // Usamos debounce para no filtrar en cada letra que se escribe
      debounce(searchQuery, (_) {
        searchQuery.value = searchQueryController.text;
        filterServicios();
      }, time: const Duration(milliseconds: 300));
    });
    fetchServicios();
  }

  void filterServicios() {
    final query = searchQuery.value.toLowerCase();
    var filteredList = List<Servicio>.from(_allServicios);

    // 1. Filtrar por nombre (búsqueda de texto)
    if (query.isNotEmpty) {
      filteredList = filteredList
          .where((s) => s.nombre.toLowerCase().contains(query))
          .toList();
    }

    // 2. Filtrar por tipo de cobro
    if (selectedTipoCobro.value != 'Todos') {
      filteredList = filteredList
          .where((s) => s.tipoCobro == selectedTipoCobro.value)
          .toList();
    }

    servicios.value = filteredList;
  }

  void clearFilters() {
    searchQueryController.clear();
    selectedTipoCobro.value = 'Todos';
    filterServicios();
  }

  void changeTipoCobroFilter(String? newType) {
    if (newType != null) {
      selectedTipoCobro.value = newType;
      filterServicios();
    }
  }

  Future<void> fetchServicios() async {
    try {
      isLoading.value = true;
      final result = await _apiService.getServicios();
      _allServicios = result;
      filterServicios();
    } on Exception {
      Get.snackbar('Error', 'No se pudieron cargar los servicios.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteServicio(int id) async {
    try {
      await _apiService.deleteServicio(id);
      // Eliminamos el servicio de la lista local para una UI instantánea
      _allServicios.removeWhere((s) => s.id == id);
      filterServicios();
      Get.snackbar('Éxito', 'Servicio eliminado correctamente.');
    } on Exception {
      Get.snackbar('Error', 'No se pudo eliminar el servicio.');
    }
  }

  /// Guarda un servicio (ya sea creando uno nuevo o actualizando uno existente).
  Future<void> saveServicio(Map<String, dynamic> data, {int? id}) async {
    try {
      if (id == null) {
        // Creando un nuevo servicio
        await _apiService.createServicio(data);
        Get.snackbar('Éxito', 'Servicio creado correctamente.');
      } else {
        // Actualizando un servicio existente
        await _apiService.updateServicio(id, data);
        Get.snackbar('Éxito', 'Servicio actualizado correctamente.');
      }

      // Cerramos el formulario y refrescamos la lista
      Get.back();
      await fetchServicios();
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar el servicio. Verifica los datos. ${e.toString()}',
      );
    }
  }
}
