import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/cotizacion_model.dart';
import '../../../global/custom_button.dart';
import '../../../global/styles/app_colors.dart';
import '../../../global/styles/app_text_styles.dart';
import '../../../global/widgets/custom_dropdown_form_field.dart';
import '../../../global/widgets/custom_scaffold.dart';
import '../../../global/widgets/custom_text_form_field.dart';
import '../../../global/widgets/loading_indicator.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/url_launcher_utils.dart';
import '../../auth/auth_controller.dart';
import 'list_controller.dart';

class CotizacionesListScreen extends StatefulWidget {
  const CotizacionesListScreen({super.key});

  @override
  State<CotizacionesListScreen> createState() => CotizacionesListScreenState();
}

class CotizacionesListScreenState extends State<CotizacionesListScreen> {
  final ListController controller = Get.find<ListController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();

    controller.searchQueryController.addListener(() {
      controller.searchQuery.value = controller.searchQueryController.text;
    });

    debounce(
      controller.searchQuery,
      (_) => controller.filterCotizaciones(),
      time: const Duration(milliseconds: 300),
    );

    if (authController.isAuthenticated.value) {
      controller.fetchAllCotizaciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return CustomScaffold(
      showDrawer: true,
      showBackButton: true,
      title: 'Listado de Cotizaciones',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: controller.fetchAllCotizaciones,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: controller.searchQueryController,
                    hintText: 'Buscar por nombre...',
                    labelText: '',
                    suffixIcon: Obx(
                      () => controller.searchQuery.value.isEmpty
                          ? const SizedBox.shrink()
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: controller.searchQueryController.clear,
                            ),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFilterModal(context),
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtros',
                ),
              ],
            ),
          ),
          Obx(_buildActiveFilters),
          Expanded(
            child: Obx(() {
              // 1. Estado de Carga
              if (controller.isLoading.value) {
                return const AppLoadingIndicator();
              }

              // 2. Estado de Error
              if (controller.errorMessage.value != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error: ${controller.errorMessage.value}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText1,
                    ),
                  ),
                );
              }

              // 3. Estado de Lista Vacía
              if (controller.cotizacionesList.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay cotizaciones para mostrar.',
                    style: AppTextStyles.bodyText1,
                  ),
                );
              }

              // 4. Estado con Datos (La Lista)
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  8,
                  8,
                  8,
                  8.0 + bottomPadding,
                ),
                itemCount: controller.cotizacionesList.length,
                itemBuilder: (context, index) {
                  final cotizacion = controller.cotizacionesList[index];
                  return _CotizacionCard(cotizacion: cotizacion);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16.0 + bottomPadding),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Wrap(
          // Usamos Wrap para que se ajuste bien en cualquier pantalla
          runSpacing: 16,
          children: [
            const Text('Filtros Avanzados', style: AppTextStyles.headline2),
            const Divider(),

            // Filtro de Estado (el que ya tenías)
            Obx(
              () => CustomDropdownFormField(
                labelText: 'Estado',
                value: controller.selectedStatus.value,
                items:
                    [
                          'Todos',
                          'confirmado',
                          'pendiente',
                          'cancelado',
                          'en revisión',
                          'contactado',
                        ]
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.capitalizeFirst!),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  controller.selectedStatus.value = newValue ?? 'Todos';
                },
              ),
            ),

            // ¡NUEVO! Filtro por Tipo de Evento
            Obx(
              () => CustomDropdownFormField(
                labelText: 'Tipo de Evento',
                value: controller
                    .selectedEventType
                    .value, // Necesitarás añadir esto al controller
                items:
                    [
                          {'display': 'Todos', 'value': 'Todos'},
                          {'display': 'Evento Social', 'value': 'Social'},
                          {
                            'display': 'Evento Empresarial',
                            'value': 'Empresarial',
                          },
                          {'display': 'Otro', 'value': 'Otro'},
                        ]
                        .map(
                          (tipo) => DropdownMenuItem(
                            value: tipo['value'],
                            child: Text(tipo['display']!),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  controller.selectedEventType.value = newValue ?? 'Todos';
                },
              ),
            ),

            // ¡NUEVO! Filtro por Rango de Fechas
            CustomButton(
              text: 'Filtrar por Fecha',
              onPress: () async {
                // Lógica para mostrar un date range picker
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  controller.setDateRange(picked.start, picked.end);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  onPress: () {
                    controller.clearFilters(); // Función para limpiar filtros
                    Get.back(); // Cierra el modal
                  },
                  text: 'Limpiar Filtros',
                ),
                CustomButton(
                  onPress: () {
                    controller.filterCotizaciones(); // Aplica los filtros
                    Get.back(); // Cierra el modal
                  },
                  text: 'Aplicar',
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true, // Importante para que no lo tape el teclado
    );
  }

  Widget _buildActiveFilters() {
    final activeFilters = <Widget>[];
    final format = DateFormat('dd/MM/yy');

    if (controller.selectedStatus.value != 'Todos') {
      activeFilters.add(
        Chip(
          label: Text(
            'Estado: ${controller.selectedStatus.value.capitalizeFirst}',
          ),
          onDeleted: () => controller.changeStatusFilter('Todos'),
        ),
      );
    }

    if (controller.selectedEventType.value != 'Todos') {
      activeFilters.add(
        Chip(
          label: Text('Tipo: ${controller.selectedEventType.value}'),
          onDeleted: () {
            controller.selectedEventType.value = 'Todos';
            controller.filterCotizaciones();
          },
        ),
      );
    }

    if (controller.startDate.value != null) {
      activeFilters.add(
        Chip(
          label: Text(
            'Fecha: ${format.format(controller.startDate.value!)} - ${format.format(controller.endDate.value!)}',
          ),
          onDeleted: () {
            controller.startDate.value = null;
            controller.endDate.value = null;
            controller.filterCotizaciones();
          },
        ),
      );
    }

    if (activeFilters.isEmpty) {
      return const SizedBox.shrink(); // No muestra nada si no hay filtros
    }

    // Usamos un Wrap para que las píldoras se ajusten si son muchas
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(spacing: 8, runSpacing: 4, children: activeFilters),
    );
  }
}

class _CotizacionCard extends StatelessWidget {

  const _CotizacionCard({required this.cotizacion});
  final Cotizacion cotizacion;

  @override
  Widget build(BuildContext context) {
    // Formateador para la moneda
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navegar a la pantalla de detalles al tocar la tarjeta
          Get.toNamed(
            AppRoutes.COTIZACION_DETAIL.replaceAll(
              ':id',
              cotizacion.id.toString(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- FILA SUPERIOR: Cliente y Estado ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cotizacion.nombreCompleto,
                          style: AppTextStyles.headline3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${cotizacion.id} | Tel: ${cotizacion.whatsapp ?? "N/A"}',
                          style: AppTextStyles.bodyText1,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: cotizacion.status),
                ],
              ),
              const Divider(height: 24),

              // --- FILA DE DETALLES: Fecha, Invitados, Total ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoColumn(
                    title: 'Fecha Evento',
                    value: cotizacion.fechaEvento,
                  ),
                  _InfoColumn(
                    title: 'Invitados',
                    value: cotizacion.cantidadInvitados.toString(),
                  ),
                  _InfoColumn(
                    title: 'Total Est.',
                    value: currencyFormatter.format(cotizacion.totalEstimado),
                    isValueBold: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- FILA DE ACCIONES ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                    tooltip: 'Ver Detalles',
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.COTIZACION_DETAIL.replaceAll(
                          ':id',
                          cotizacion.id.toString(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      color: AppColors.secondary,
                    ),
                    tooltip: 'WhatsApp',
                    onPressed: () {
                      launchWhatsApp(cotizacion.whatsapp.toString());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar',
                    onPressed: () {
                      // Mostrar un diálogo de confirmación antes de eliminar
                      Get.defaultDialog(
                        title: 'Confirmar Eliminación',
                        middleText:
                            '¿Estás seguro de que quieres eliminar la cotización #${cotizacion.id}?',
                        textConfirm: 'Eliminar',
                        textCancel: 'Cancelar',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          Get.find<ListController>().deleteCotizacion(
                            cotizacion.id,
                          );
                          Get.back();
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pequeño widget para mostrar el estado con un color distintivo.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

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

  @override
  Widget build(BuildContext context) => Chip(
      label: Text(
        status,
        style: AppTextStyles.bodyText1.copyWith(color: AppColors.textLight),
      ),
      backgroundColor: _getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
}

/// Widget para mostrar una columna de información (título y valor).
class _InfoColumn extends StatelessWidget {

  const _InfoColumn({
    required this.title,
    required this.value,
    this.isValueBold = false,
  });
  final String title;
  final String value;
  final bool isValueBold;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyText2),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyText1.copyWith(
            fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
}
