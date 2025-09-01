import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/cotizacion_model.dart';
import '../../../data/services/notification_service.dart';
import '../../../global/styles/app_colors.dart';
import '../../../global/styles/app_text_styles.dart';
import '../../../global/widgets/custom_scaffold.dart';
import '../../../global/widgets/loading_indicator.dart';
import '../../auth/auth_controller.dart';
import 'detail_controller.dart';

class CotizacionDetailScreen extends StatefulWidget {
  const CotizacionDetailScreen({super.key});

  @override
  State<CotizacionDetailScreen> createState() => _CotizacionDetailScreenState();
}

class _CotizacionDetailScreenState extends State<CotizacionDetailScreen> {
  final DetailController controller = Get.find<DetailController>();
  final AuthController authController = Get.find<AuthController>();
  final NotificationService notificationService =
      Get.find<NotificationService>();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmado':
        return AppColors.statusGreen;
      case 'pendiente':
        return AppColors.amber;
      case 'cancelado':
        return AppColors.statusRed;
      case 'en revisión':
        return AppColors.blue;
      case 'contactado':
        return AppColors.statusBlue;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmado':
        return Icons.check_circle_outline;
      case 'pendiente':
        return Icons.access_time_outlined;
      case 'cancelado':
        return Icons.cancel_outlined;
      case 'en revisión':
        return Icons.search;
      case 'contactado':
        return Icons.chat_bubble_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.parameters.containsKey('id')) {
        final idString = Get.parameters['id'];
        final id = int.tryParse(idString ?? '');
        if (id != null) {
          controller.fetchCotizacionById(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Obx(
      () => CustomScaffold(
        showBackButton: true,
        showDrawer: false,
        title: controller.cotizacionActual.value != null
            ? 'Detalle de Cotización #${controller.cotizacionActual.value!.id}'
            : 'Detalle de Cotización',
        body: _buildBody(bottomPadding),
      ),
    );
  }

  Widget _buildBody(double bottomPadding) => Obx(() {
    if (controller.isLoading.value) {
      return const AppLoadingIndicator();
    }
    if (controller.cotizacionActual.value == null) {
      return const Center(
        child: Text(
          'No se pudo cargar la cotización.',
          style: AppTextStyles.bodyText1,
        ),
      );
    }
    return _buildDetails(controller.cotizacionActual.value!, bottomPadding);
  });

  Widget _buildDetails(Cotizacion cotizacion, double bottomPadding) => ListView(
    padding: EdgeInsets.fromLTRB(16, 16, 16, 16.0 + bottomPadding),
    children: [
      _buildHeader(cotizacion),
      const SizedBox(height: 16),
      _buildInfoClienteCard(cotizacion),
      const SizedBox(height: 16),
      _buildDetallesEventoCard(cotizacion),
      const SizedBox(height: 16),
      _buildLogisticaCard(cotizacion),
      const SizedBox(height: 16),
      _buildEstadoCard(cotizacion),
      const SizedBox(height: 16),
      _buildResumenFinancieroCard(cotizacion),
      const SizedBox(height: 16),
      Obx(() {
        if (authController.isAuthenticated.value) {
          return _buildCambiarEstadoCard(cotizacion);
        }
        return const SizedBox.shrink();
      }),
      const SizedBox(height: 16),
      _buildServiciosSeleccionadosCard(cotizacion),
    ],
  );

  Widget _buildHeader(Cotizacion cotizacion) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime.parse(cotizacion.fechaCreacion));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cotización #${cotizacion.id} - Solicitada el $formattedDate',
          style: AppTextStyles.bodyText1,
        ),
      ],
    );
  }

  Widget _buildInfoClienteCard(Cotizacion cotizacion) => _DetailCard(
    title: 'Información del Cliente',
    children: [
      _buildDetailRowWithIcon(
        Icons.person,
        'Nombre',
        cotizacion.nombreCompleto,
      ),
      _buildDetailRowWithIcon(
        FontAwesomeIcons.whatsapp,
        'WhatsApp',
        cotizacion.whatsapp ?? 'N/A',
      ),
      _buildDetailRowWithIcon(
        Icons.business,
        'Empresa',
        cotizacion.nombreEmpresa ?? 'N/A',
      ),
    ],
  );

  Widget _buildDetallesEventoCard(Cotizacion cotizacion) {
    final eventDate =
        cotizacion.horaEvento != null && cotizacion.horaEvento!.isNotEmpty
        ? DateFormat('dd/MM/yyyy a las hh:mm a').format(
            DateTime.parse(
              '${cotizacion.fechaEvento} ${cotizacion.horaEvento}',
            ),
          )
        : DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(cotizacion.fechaEvento));

    return _DetailCard(
      title: 'Detalles del Evento',
      children: [
        _buildDetailRowWithIcon(
          Icons.event_seat,
          'Tipo de Evento',
          cotizacion.tipoEvento ?? 'N/A',
        ),
        _buildDetailRowWithIcon(
          Icons.calendar_today,
          'Fecha y Hora',
          eventDate,
        ),
        _buildDetailRowWithIcon(
          Icons.people,
          'Invitados',
          cotizacion.cantidadInvitados.toString(),
        ),
        _buildDetailRowWithIcon(
          Icons.location_on,
          'Dirección',
          cotizacion.direccionEvento ?? 'N/A',
        ),
        // const SizedBox(height: 16),
        // ElevatedButton.icon(
        //   icon: const Icon(Icons.notification_add),
        //   label: const Text('Crear Recordatorio'),
        //   onPressed: () => _showReminderDialog(cotizacion),
        // ),
      ],
    );
  }

  // void _showReminderDialog(Cotizacion cotizacion) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => AlertDialog(
  //       title: const Text('Programar Recordatorio'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             title: const Text('1 día antes'),
  //             onTap: () async {
  //               await AndroidFlutterLocalNotificationsPlugin()
  //                   .requestExactAlarmsPermission();
  //               _scheduleReminder(cotizacion, const Duration(seconds: 3));
  //               Get.back();
  //             },
  //           ),
  //           ListTile(
  //             title: const Text('3 días antes'),
  //             onTap: () async {
  //               await AndroidFlutterLocalNotificationsPlugin()
  //                   .requestExactAlarmsPermission();
  //               _scheduleReminder(cotizacion, const Duration(days: 3));
  //               Get.back();
  //             },
  //           ),
  //           ListTile(
  //             title: const Text('1 semana antes'),
  //             onTap: () async {
  //               await AndroidFlutterLocalNotificationsPlugin()
  //                   .requestExactAlarmsPermission();
  //               _scheduleReminder(cotizacion, const Duration(days: 7));
  //               Get.back();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _scheduleReminder(Cotizacion cotizacion, Duration offset) {
  //   final eventDate = DateTime.parse(cotizacion.fechaEvento);
  //   final scheduledDate = eventDate.subtract(offset);

  //   notificationService.scheduleQuoteReminder(
  //     cotizacion.id,
  //     'Recordatorio de tu Evento',
  //     'Tu evento "${cotizacion.tipoEvento}" es en ${offset.inDays} día(s).',
  //     scheduledDate,
  //   );

  //   Get.snackbar(
  //     'Recordatorio Programado',
  //     'Se te notificará ${offset.inDays} día(s) antes del evento.',
  //     snackPosition: SnackPosition.BOTTOM,
  //   );
  // }

  Widget _buildLogisticaCard(Cotizacion cotizacion) => _DetailCard(
    title: 'Logística y Requisitos',
    children: [
      _buildDetailRowWithIcon(
        Icons.build,
        'Montaje',
        cotizacion.dificultadMontaje ?? 'N/A',
      ),
      _buildDetailRowWithIcon(
        Icons.add_box,
        'Adicionales',
        cotizacion.requisitosAdicionales ?? 'N/A',
      ),
      _buildDetailRowWithIcon(
        Icons.warning,
        'Restricciones',
        cotizacion.restricciones ?? 'N/A',
      ),
      _buildDetailRowWithIcon(
        Icons.playlist_add,
        'Otros Servicios',
        cotizacion.serviciosOtros ?? 'N/A',
      ),
    ],
  );

  Widget _buildEstadoCard(Cotizacion cotizacion) => Card(
    elevation: 2,
    color: _getStatusColor(cotizacion.status),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(cotizacion.status),
            color: AppColors.textLight,
            size: 30,
          ),
          const SizedBox(width: 16),
          Text(
            'Estado: ${cotizacion.status}',
            style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    ),
  );

  Widget _buildResumenFinancieroCard(Cotizacion cotizacion) => _DetailCard(
    title: 'Resumen Financiero',
    children: [
      _buildFinancialRow('Costo Base', cotizacion.totalBase.toString()),
      _buildFinancialRow(
        'Ajuste por IA',
        cotizacion.costoAdicionalIa.toString(),
      ),
      const Divider(),
      _buildFinancialRow(
        'Total Estimado',
        cotizacion.totalEstimado.toString(),
        isTotal: true,
      ),
      const SizedBox(height: 16),
      Text(
        'Justificación de IA:',
        style: Theme.of(context).textTheme.labelLarge,
      ),
      const SizedBox(height: 4),
      Text(cotizacion.justificacionIa),
    ],
  );

  Widget _buildCambiarEstadoCard(Cotizacion cotizacion) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '-- Cambiar estado --',
              ),
              initialValue: cotizacion.status,
              items:
                  [
                        'Pendiente',
                        'En Revisión',
                        'Contactado',
                        'Confirmado',
                        'Cancelado',
                      ]
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateCotizacionStatus(cotizacion.id, value);
                }
              },
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildServiciosSeleccionadosCard(Cotizacion cotizacion) => _DetailCard(
    title: 'Servicios Seleccionados',
    children: [
      if (cotizacion.serviciosSeleccionados != null &&
          cotizacion.serviciosSeleccionados!.isNotEmpty)
        ...cotizacion.serviciosSeleccionados!.map(
          (servicio) => ListTile(
            leading: const Icon(Icons.check, color: AppColors.green),
            title: Text(servicio.nombre),
          ),
        )
      else
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'No hay servicios seleccionados.',
            style: AppTextStyles.bodyText1,
          ),
        ),
    ],
  );

  Widget _buildDetailRowWithIcon(IconData icon, String label, String value) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.grey),
            const SizedBox(width: 16),
            Text('$label:', style: AppTextStyles.bodyText1),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyText1.copyWith(color: AppColors.grey),
              ),
            ),
          ],
        ),
      );

  Widget _buildFinancialRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          )
        : AppTextStyles.bodyText2;
    final valueStyle = isTotal
        ? AppTextStyles.bodyText1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.blue,
          )
        : AppTextStyles.bodyText2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('\$${value.toString()}', style: valueStyle),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyText1),
          const SizedBox(height: 8),
          const Divider(),
          ...children,
        ],
      ),
    ),
  );
}
