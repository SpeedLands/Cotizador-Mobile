import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/calendario_evento_model.dart';
import '../../data/services/api_service.dart';
import '../../utils/logger.dart';

class CalendarioController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // --- ESTADO DEL CALENDARIO ---
  var isLoading = true.obs; // Inicia en true para el primer fetch
  var errorMessage = Rx<String?>(null);

  var events = <DateTime, List<CalendarioEvento>>{}.obs;

  var focusedDay = DateTime.now().obs;
  var selectedDay = Rx<DateTime?>(null);
  var selectedEvents = <CalendarioEvento>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Establece el día seleccionado inicial y obtiene los eventos
    selectedDay.value = _normalizeDate(focusedDay.value);
    fetchEventos();
  }

  /// Obtiene los eventos de la API y los procesa.
  Future<void> fetchEventos() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final eventosDesdeApi = await _apiService.getCalendarioEventos();
      events.value = _groupEventsByDay(eventosDesdeApi);

      // Actualiza los eventos para el día seleccionado después de obtenerlos.
      updateSelectedEvents(selectedDay.value!);
    } on Exception catch (e) {
      _handleFetchError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Agrupa una lista de eventos en un mapa por día.
  Map<DateTime, List<CalendarioEvento>> _groupEventsByDay(
    List<CalendarioEvento> eventos,
  ) {
    final Map<DateTime, List<CalendarioEvento>> groupedEvents = {};
    for (final evento in eventos) {
      final date = _normalizeDate(DateTime.parse(evento.start));
      (groupedEvents[date] ??= []).add(evento);
    }
    return groupedEvents;
  }

  /// Maneja los errores ocurridos durante la obtención de eventos.
  void _handleFetchError(Object e) {
    logger.e('Error al obtener eventos del calendario', error: e);
    if (e is DioException) {
      errorMessage.value = 'Error de red: No se pudieron cargar los eventos.';
    } else {
      errorMessage.value =
          'Ocurrió un error inesperado al procesar los eventos.';
    }
    Get.snackbar('Error', errorMessage.value!);
  }

  /// Normaliza una fecha a UTC para consistencia.
  DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  /// Devuelve la lista de eventos para un día específico.
  List<CalendarioEvento> getEventsForDay(DateTime day) =>
      events[_normalizeDate(day)] ?? [];

  /// Actualiza la lista de eventos seleccionados para un día dado.
  void updateSelectedEvents(DateTime day) {
    selectedEvents.value = getEventsForDay(day);
  }

  /// Se llama cuando el usuario toca un día en el calendario.
  void onDaySelected(DateTime day, DateTime focused) {
    final normalizedDay = _normalizeDate(day);
    if (!isSameDay(selectedDay.value, normalizedDay)) {
      selectedDay.value = normalizedDay;
      focusedDay.value = focused;
      updateSelectedEvents(normalizedDay);
    }
  }
}
