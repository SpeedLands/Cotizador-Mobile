import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/models/calendario_evento_model.dart'; // Asegúrate que la ruta sea correcta
import '../../data/services/api_service.dart';

class CalendarioController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // --- ESTADO DEL CALENDARIO ---
  var isLoading = false.obs;
  var errorMessage = Rx<String?>(null);

  var events = <DateTime, List<CalendarioEvento>>{}.obs;

  var focusedDay = DateTime.now().obs;
  var selectedDay = Rx<DateTime?>(null);
  var selectedEvents = <CalendarioEvento>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEventos();

    selectedDay.value = focusedDay.value;
    // Inicializamos la lista de eventos para el día de hoy
    // Usamos un Future.delayed para asegurar que el primer frame se construya sin problemas
    Future.delayed(Duration.zero, () {
      selectedEvents.value = getEventsForDay(selectedDay.value!);
    });
  }

  Future<void> fetchEventos() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      events.clear();

      final eventosDesdeApi = await _apiService.getCalendarioEventos();

      // --- PROCESAMOS LA LISTA PARA AGRUPARLA POR DÍA ---
      for (final evento in eventosDesdeApi) {
        // CAMBIO: Parseamos la fecha String a un objeto DateTime
        final parsedDate = DateTime.parse(evento.start);

        // Normalizamos la fecha a UTC para evitar problemas de zona horaria
        final date = DateTime.utc(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(evento);
      }
      // Actualizamos la lista de eventos para el día que ya estaba seleccionado
      if (selectedDay.value != null) {
        selectedEvents.value = getEventsForDay(selectedDay.value!);
      }
    } on Exception catch (e) {
      errorMessage.value = 'No se pudieron cargar los eventos del calendario.';
      Get.snackbar('Error', '${errorMessage.value!} $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Devuelve la lista de eventos para un día específico.
  List<CalendarioEvento> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }

  /// Se llama cuando el usuario toca un día en el calendario.
  void onDaySelected(DateTime day, DateTime focused) {
    if (!isSameDay(selectedDay.value, day)) {
      selectedDay.value = day;
      focusedDay.value = focused;
      selectedEvents.value = getEventsForDay(day);
    }
  }
}
