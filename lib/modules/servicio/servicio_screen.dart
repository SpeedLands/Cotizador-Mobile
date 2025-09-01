import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/servicio_model.dart';
import '../../global/styles/app_colors.dart';
import '../../global/styles/app_text_styles.dart';
import '../../global/widgets/active_filters_display.dart';
import '../../global/widgets/custom_dropdown_form_field.dart';
import '../../global/widgets/custom_text_form_field.dart';
import '../../global/widgets/filter_bottom_sheet.dart';
import '../../global/widgets/list_screen_layout.dart';
import '../../routes/app_routes.dart';
import 'servicio_controller.dart';

class ServiciosListScreen extends GetView<ServicioController> {
  const ServiciosListScreen({super.key});

  @override
  Widget build(BuildContext context) => ListScreenLayout<Servicio>(
    padding: EdgeInsets.fromLTRB(
      8,
      8,
      8,
      8 + MediaQuery.of(context).viewPadding.bottom,
    ),
    title: 'Gestión de Servicios',
    showDrawer: true,
    showBackButton: true,
    items: controller.servicios,
    isLoading: controller.isLoading,
    emptyMessage: 'No hay servicios creados.',
    onRefresh: () => controller.fetchServicios(),
    actions: [
      IconButton(
        onPressed: () => Get.toNamed(AppRoutes.SERVICIO_FORM),
        icon: const Icon(Icons.add),
      ),
      IconButton(
        onPressed: () => controller.fetchServicios(),
        icon: const Icon(Icons.refresh),
      ),
    ],
    headerContent: _buildSearchBar(),
    filterBuilder: Obx(
      () => ActiveFiltersDisplay(
        filters: [
          if (controller.selectedTipoCobro.value != 'Todos')
            ActiveFilter(
              label:
                  'Tipo: ${controller.selectedTipoCobro.value.replaceAll('_', ' ')}',
              onRemove: () => controller.changeTipoCobroFilter('Todos'),
            ),
        ],
      ),
    ),
    itemBuilder: (servicio) => _ServiceCard(servicio: servicio),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            labelText: '',
            controller: controller.searchQueryController,
            hintText: 'Buscar por nombre...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.searchQueryController.clear(),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtros',
          onPressed: _showFilterModal,
        ),
      ],
    ),
  );

  void _showFilterModal() {
    FilterBottomSheet.show(
      title: 'Filtros',
      filterWidgets: [
        Obx(
          () => CustomDropdownFormField(
            labelText: 'Tipo de Cobro',
            value: controller.selectedTipoCobro.value,
            items: ['Todos', 'fijo', 'por_persona', 'por_litro']
                .map(
                  (tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.replaceAll('_', ' ').capitalizeFirst!),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              controller.selectedTipoCobro.value = newValue ?? 'Todos';
            },
          ),
        ),
      ],
      onApply: () {
        controller.filterServicios();
      },
      onClear: () {
        controller.clearFilters();
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.servicio});
  final Servicio servicio;

  @override
  Widget build(BuildContext context) {
    final ServicioController controller = Get.find();

    // Formateador para mostrar el precio como moneda local (ej: $1,500.00)
    final currencyFormatter = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );
    final precio = double.tryParse(servicio.precioBase) ?? 0.0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. TÍTULO DEL SERVICIO ---
            Text(
              servicio.nombre,
              style: AppTextStyles.headline3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // --- 2. SECCIÓN DE DETALLES (PRECIO Y TIPO) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Columna para el precio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRECIO BASE',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(precio),
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Etiqueta visual para el tipo de cobro
                _TipoCobroChip(tipo: servicio.tipoCobro),
              ],
            ),
            const SizedBox(height: 16),

            // --- 3. BARRA DE ACCIONES ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                  tooltip: 'Editar',
                  onPressed: () {
                    Get.toNamed(AppRoutes.SERVICIO_FORM, arguments: servicio);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Confirmar',
                      middleText:
                          '¿Seguro que quieres eliminar "${servicio.nombre}"?',
                      textConfirm: 'Eliminar',
                      textCancel: 'Cancelar',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        controller.deleteServicio(servicio.id);
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
    );
  }
}

// --- WIDGET HELPER PARA LA ETIQUETA DE TIPO DE COBRO ---
class _TipoCobroChip extends StatelessWidget {
  const _TipoCobroChip({required this.tipo});
  final String tipo;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (tipo) {
      case 'por_persona':
        icon = Icons.group;
        color = AppColors.statusBlue;
        label = 'Por Persona';
        break;
      case 'por_litro':
        icon = Icons.local_drink;
        color = Colors.teal;
        label = 'Por Litro';
        break;
      case 'fijo':
      default:
        icon = Icons.attach_money;
        color = AppColors.statusGreen;
        label = 'Fijo';
        break;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
