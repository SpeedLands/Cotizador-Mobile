import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../global/styles/app_text_styles.dart';
import '../../global/widgets/custom_scaffold.dart';
import '../../global/widgets/loading_indicator.dart';
import '../../routes/app_routes.dart';
import 'calendario_controller.dart';

class CalendarioScreen extends GetView<CalendarioController> {
  const CalendarioScreen({super.key});

  @override
  Widget build(BuildContext context) => CustomScaffold(
    showBackButton: true,
    showDrawer: true,
    title: 'Calendario de Eventos',
    actions: [
      IconButton(
        onPressed: () {
          controller.fetchEventos();
        },
        icon: const Icon(Icons.replay_outlined),
      ),
    ],
    body: Obx(() {
      if (controller.isLoading.value) {
        return const AppLoadingIndicator();
      }

      return RefreshIndicator(
        onRefresh: () => controller.fetchEventos(),
        child: Column(
          children: [
            // --- EL WIDGET DEL CALENDARIO ---
            TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: controller.focusedDay.value,
              selectedDayPredicate: (day) =>
                  isSameDay(controller.selectedDay.value, day),
              onDaySelected: controller.onDaySelected,
              eventLoader: (day) => controller.getEventsForDay(day),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
            const SizedBox(height: 8),

            // --- LA LISTA DE EVENTOS DEL DÍA SELECCIONADO ---
            Expanded(child: _buildEventList()),
          ],
        ),
      );
    }),
  );

  /// Construye la lista de eventos para el día seleccionado.
  Widget _buildEventList() => Obx(() {
    if (controller.selectedEvents.isEmpty) {
      return const Center(
        child: Text(
          'No hay eventos para este día.',
          style: AppTextStyles.bodyText1,
        ),
      );
    }

    return ListView.builder(
      itemCount: controller.selectedEvents.length,
      itemBuilder: (context, index) {
        final evento = controller.selectedEvents[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            // CAMBIO: Usamos 'title' en lugar de 'nombreCompleto'
            title: Text(evento.title),
            subtitle: Text('ID Cotización: ${evento.id}'),
            leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
            onTap: () {
              Get.toNamed(
                '${AppRoutes.COTIZACION_DETAIL.replaceAll(':id', '')}${evento.id}',
              );
            },
          ),
        );
      },
    );
  });
}
