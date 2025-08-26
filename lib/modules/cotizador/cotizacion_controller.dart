import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/cotizacion_model.dart';
import '../../data/models/servicio_model.dart';
import '../../data/services/api_service.dart';
import '../../routes/app_routes.dart';

class CotizacionController extends GetxController {
  // Inyección de dependencias para nuestro servicio de API
  final ApiService _apiService = Get.find<ApiService>();

  var serviciosRegulares = <Servicio>[].obs;
  var serviciosSeleccionados = <int>{}.obs;
  var modalidades = <Servicio>[].obs;
  var modalidadSeleccionada = Rx<int?>(null);
  var subtotal = 0.0.obs;
  var resumenItems = <Map<String, String>>[].obs;

  final nombreCompletoController = TextEditingController();
  var whatsappNumber = ''.obs;
  var tipoEvento = 'Social'.obs;
  final nombreEmpresaController = TextEditingController();
  final direccionEventoController = TextEditingController();
  final fechaEventoController = TextEditingController();
  final horaEventoController = TextEditingController();
  final horarioConsumoController = TextEditingController();
  final cantidadInvitadosController = TextEditingController();
  final serviciosOtrosController = TextEditingController();
  var mesaMantel = 'Si'.obs;
  final mesaMantelOtroController = TextEditingController();
  var personalServicio = 'No'.obs;
  var accesoEnchufe = 'Si'.obs;
  final dificultadMontajeController = TextEditingController();
  var comoSupiste = 'Recomendacion'.obs;
  final comoSupisteOtroController = TextEditingController();
  var tipoConsumidores = 'Hombres'.obs;
  final restriccionesController = TextEditingController();
  final requisitosAdicionalesController = TextEditingController();
  final presupuestoController = TextEditingController();

  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);
  var cotizacionInvitado = Rx<Cotizacion?>(null);
  var fechasOcupadas = <DateTime>[].obs;

  Future<void> inicializarCotizador() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      // Hacemos ambas llamadas en paralelo para más eficiencia
      await Future.wait([fetchServiciosDisponibles(), fetchFechasOcupadas()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchServiciosDisponibles() async {
    try {
      final todosLosServicios = await _apiService.getServicios();

      // Separamos las listas
      serviciosRegulares.value = todosLosServicios
          .where((s) => !s.nombre.startsWith('Modalidad:'))
          .toList();
      modalidades.value = todosLosServicios
          .where((s) => s.nombre.startsWith('Modalidad:'))
          .toList();

      // Pre-seleccionar la modalidad por defecto (la que tiene precio 0)
      final modalidadDefault = modalidades.firstWhere(
        (m) => double.parse(m.precioBase) == 0,
        orElse: () => modalidades
            .first, // Si ninguna tiene precio 0, selecciona la primera
      );
      modalidadSeleccionada.value = modalidadDefault.id;
    } on Exception catch (e) {
      errorMessage.value =
          'No se pudieron cargar los servicios. ${e.toString()}';
      Get.snackbar('Error', errorMessage.value!);
    }
  }

  Future<void> fetchFechasOcupadas() async {
    try {
      final fechasString = await _apiService.getFechasOcupadas();
      fechasOcupadas.value = fechasString.map(DateTime.parse).toList();
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos. ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      // No mostramos snackbar para no ser intrusivos
    }
  }

  Future<void> loadGuestCotizacion() async {
    await _handleApiCall(
      apiCall: () async {
        final prefs = await SharedPreferences.getInstance();
        final cotizacionId = prefs.getInt('guest_cotizacion_id');
        if (cotizacionId != null) {
          final cotizacion = await _apiService.getCotizacionById(cotizacionId);
          cotizacionInvitado.value = cotizacion;
        }
        return null;
      },
      onError: (e) async {
        errorMessage.value =
            'No se pudo cargar tu cotización guardada. ${e.toString()}';
        await clearGuestSession();
      },
    );
  }

  Future<void> crearCotizacionInvitado() async {
    await _handleApiCall(
      apiCall: () async {
        final cotizacionData = _buildCotizacionData();
        final response = await _apiService.createCotizacion(cotizacionData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          'guest_cotizacion_id',
          response['cotizacion_id'] as int,
        );
        await prefs.setString(
          'guest_token',
          response['guest_token'].toString(),
        );

        return response['cotizacion_id'];
      },
      onSuccess: (id) {
        Get
          ..snackbar('Éxito', 'Tu cotización ha sido enviada correctamente.')
          ..toNamed('${AppRoutes.COTIZACION_DETAIL.replaceAll(':id', '')}$id');
      },
      onError: (e) {
        errorMessage.value = 'No se pudo crear la cotización.';
        Get.snackbar('Error', errorMessage.value!);
      },
    );
  }

  Future<void> clearGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_cotizacion_id');
    await prefs.remove('guest_token');
    cotizacionInvitado.value = null;
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
        SchedulerBinding.instance.addPostFrameCallback((_) {
          onError(e);
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Error',
            'Ocurrió un error inesperado: ${e.toString()}',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  void recalcularTotal() {
    final cantidadInvitados =
        int.tryParse(cantidadInvitadosController.text) ?? 0;
    final litrosAgua = (cantidadInvitados / 6).ceil();
    double totalCalculado = 0;
    final items = <Map<String, String>>[];

    for (final servicio in serviciosRegulares) {
      if (serviciosSeleccionados.contains(servicio.id)) {
        // Validar si el servicio está habilitado por min_personas
        if (cantidadInvitados >= servicio.minPersonas) {
          double costoItem = 0;
          String nombreItem = servicio.nombre;

          switch (servicio.tipoCobro) {
            case 'por_persona':
              costoItem = double.parse(servicio.precioBase) * cantidadInvitados;
              break;
            case 'por_litro':
              costoItem = double.parse(servicio.precioBase) * litrosAgua;
              nombreItem += ' (${litrosAgua}L)';
              break;
            default: // 'fijo'
              costoItem = double.parse(servicio.precioBase);
              break;
          }
          totalCalculado += costoItem;
          items.add({
            'nombre': nombreItem,
            'costo': costoItem.toStringAsFixed(2),
          });
        }
      }
    }

    if (modalidadSeleccionada.value != null) {
      final modalidad = modalidades.firstWhere(
        (m) => m.id == modalidadSeleccionada.value,
      );
      final costoModalidad = double.parse(modalidad.precioBase);
      if (costoModalidad >= 0) {
        // Siempre se añade, incluso si es 0
        totalCalculado += costoModalidad;
        items.add({
          'nombre':
              'Modalidad: ${modalidad.nombre.replaceFirst('Modalidad: ', '')}',
          'costo': costoModalidad.toStringAsFixed(2),
        });
      }
    }

    subtotal.value = totalCalculado;
    resumenItems.value = items;
  }

  Future<void> seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ), // 2 años en el futuro
      // --- ¡AQUÍ DESHABILITAMOS LAS FECHAS! ---
      selectableDayPredicate: (DateTime day) {
        // No permitir Domingos (ejemplo)
        // if (day.weekday == DateTime.sunday) return false;

        // No permitir fechas de la lista de ocupadas
        for (final fechaOcupada in fechasOcupadas) {
          if (day.year == fechaOcupada.year &&
              day.month == fechaOcupada.month &&
              day.day == fechaOcupada.day) {
            return false;
          }
        }
        return true;
      },
    );
    if (picked != null) {
      // Formateamos la fecha para la UI y para la API
      final String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      fechaEventoController.text = formattedDate;
    }
  }

  Future<void> seleccionarHora(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      // Formateamos la hora a "HH:mm" (ej: "09:05" o "14:30") para la API
      final formattedTime =
          '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  void toggleServicio(int servicioId) {
    if (serviciosSeleccionados.contains(servicioId)) {
      serviciosSeleccionados.remove(servicioId);
    } else {
      serviciosSeleccionados.add(servicioId);
    }
    recalcularTotal();
  }

  void seleccionarModalidad(int? modalidadId) {
    if (modalidadId != null) {
      modalidadSeleccionada.value = modalidadId;
      recalcularTotal();
    }
  }

  Map<String, dynamic> _buildCotizacionData() {
    final List<int> todosLosServiciosIds = [...serviciosSeleccionados];
    if (modalidadSeleccionada.value != null) {
      todosLosServiciosIds.add(modalidadSeleccionada.value!);
    }
    return {
      // --- Datos del cliente y evento ---
      'nombre_completo': nombreCompletoController.text,
      'whatsapp': whatsappNumber.value.toString(),
      'tipo_evento': tipoEvento.value.toString(),
      'nombre_empresa': nombreEmpresaController.text,
      'direccion_evento': direccionEventoController.text,
      'fecha_evento': fechaEventoController.text,
      'hora_evento': horaEventoController.text,
      'horario_consumo': horarioConsumoController.text,

      // --- Datos de servicios ---
      'cantidad_invitados': int.tryParse(cantidadInvitadosController.text) ?? 0,
      'servicios': todosLosServiciosIds.toList(),
      'servicios_otros': serviciosOtrosController.text,

      // --- Detalles finales ---
      'como_supiste': comoSupiste.value.toString(),
      'como_supiste_otro': comoSupisteOtroController.text,
      'mesa_mantel': mesaMantel.value.toString(),
      'mesa_mantel_otro': mesaMantelOtroController.text,
      'personal_servicio': personalServicio.value.toString(),
      'acceso_enchufe': accesoEnchufe.value.toString(),
      'dificultad_montaje': dificultadMontajeController.text,
      'tipo_consumidores': tipoConsumidores.value.toString(),
      'restricciones': restriccionesController.text,
      'requisitos_adicionales': requisitosAdicionalesController.text,
      'presupuesto': presupuestoController.text,
    };
  }
}
