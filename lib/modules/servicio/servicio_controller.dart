import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/servicio_model.dart';
import '../../data/services/api_service.dart';
import '../../utils/logger.dart';

class ServicioController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // --- ESTADO ---
  var isLoading = true.obs;
  var _allServicios = <Servicio>[];
  var servicios = <Servicio>[].obs;

  // --- FILTROS ---
  final searchQueryController = TextEditingController();
  var searchQuery =
      ''.obs; // Reintroducido para un debouncing correcto y limpio
  var selectedTipoCobro = 'Todos'.obs;

  @override
  void onInit() {
    super.onInit();
    // Este worker es la forma más limpia en GetX para reaccionar a cambios
    // en un observable con un debounce.
    debounce(
      searchQuery,
      (_) => filterServicios(),
      time: const Duration(milliseconds: 350),
    );

    // El listener simplemente actualiza el observable.
    searchQueryController.addListener(() {
      searchQuery.value = searchQueryController.text;
    });

    fetchServicios();
  }

  @override
  void onClose() {
    searchQueryController.dispose();
    super.onClose();
  }

  /// Envoltura genérica para llamadas a la API.
  Future<void> _callApi(
    Future<void> Function() apiCall, {
    String? successMessage,
  }) async {
    try {
      isLoading.value = true;
      await apiCall();
      if (successMessage != null) {
        Get.snackbar(
          'Éxito',
          successMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Error de red desconocido.';

      // 2. Guarda el 'data' en una variable local para facilitar la lectura.
      final responseData = e.response?.data;

      // 3. ¡LA CLAVE! Comprueba si 'data' es realmente un Mapa.
      if (responseData is Map<String, dynamic>) {
        // 4. Si es un mapa, ahora sí puedes acceder a la clave de forma segura.
        // También es buena práctica verificar si el mensaje existe y no es nulo.
        errorMessage =
            responseData['message'] as String? ??
            'El servidor no proporcionó un mensaje de error.';
      } else if (responseData != null) {
        // 5. (Opcional pero recomendado) Si no es un mapa pero no es nulo,
        // conviértelo a String para mostrar algo de información.
        errorMessage = responseData.toString();
      }
      Get.snackbar(
        'Error de API',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      logger.e('Error de Dio en ServicioController', error: e);
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'Ocurrió un error inesperado.',
        snackPosition: SnackPosition.BOTTOM,
      );
      logger.e('Error inesperado en ServicioController', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtra la lista de servicios basándose en el `searchQuery` y el tipo de cobro.
  void filterServicios() {
    final query = searchQuery.value.toLowerCase();
    servicios.value = _allServicios.where((servicio) {
      final nameMatch = servicio.nombre.toLowerCase().contains(query);
      final typeMatch =
          selectedTipoCobro.value == 'Todos' ||
          servicio.tipoCobro == selectedTipoCobro.value;
      return nameMatch && typeMatch;
    }).toList();
  }

  /// Limpia todos los filtros y muestra la lista completa.
  void clearFilters() {
    searchQueryController.clear();
    selectedTipoCobro.value = 'Todos';
    // El listener de searchQuery se encargará de actualizar la UI
  }

  /// Cambia el filtro de tipo de cobro y aplica los filtros.
  void changeTipoCobroFilter(String? newType) {
    if (newType != null) {
      selectedTipoCobro.value = newType;
      filterServicios(); // El filtro de tipo de cobro es inmediato
    }
  }

  /// Obtiene todos los servicios desde la API.
  Future<void> fetchServicios() async {
    await _callApi(() async {
      final result = await _apiService.getServicios();
      _allServicios = result;
      filterServicios();
    });
  }

  /// Elimina un servicio por su ID.
  Future<void> deleteServicio(int id) async {
    await _callApi(() async {
      await _apiService.deleteServicio(id);
      _allServicios.removeWhere((s) => s.id == id);
      filterServicios();
    }, successMessage: 'Servicio eliminado correctamente.');
  }

  /// Guarda un servicio (crea o actualiza).
  Future<void> saveServicio(Map<String, dynamic> data, {int? id}) async {
    final isCreating = id == null;
    await _callApi(
      () async {
        if (isCreating) {
          await _apiService.createServicio(data);
        } else {
          await _apiService.updateServicio(id, data);
        }
        Get.back();
        await fetchServicios();
      },
      successMessage:
          'Servicio ${isCreating ? 'creado' : 'actualizado'} correctamente.',
    );
  }
}
