import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/cotizacion_resumen_model.dart';
import '../../../global/styles/app_colors.dart';
import '../../../global/styles/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/logger.dart';

class ActivityListItem extends StatelessWidget {
  const ActivityListItem({required this.quote, super.key});
  final CotizacionResumen quote;

  @override
  Widget build(BuildContext context) {
    // --- Lógica para definir colores e íconos ---
    // Variables que cambiaremos según el estado
    Color iconColor;
    Color backgroundColor;
    Color statusTextColor;
    IconData iconData;

    // Usamos toLowerCase() para evitar problemas con mayúsculas/minúsculas
    switch (quote.status.toString().toLowerCase()) {
      case 'confirmado':
        iconColor = AppColors.statusGreen;
        backgroundColor = AppColors.statusGreenLight;
        statusTextColor = AppColors.statusGreen;
        iconData = Icons.check_circle_outline;
        break;
      case 'en revisión':
        iconColor = AppColors.blue;
        backgroundColor = AppColors.statusBlueLight;
        statusTextColor = AppColors.statusBlue;
        iconData = Icons.search;
        break;
      case 'contactado':
        iconColor = AppColors.statusBlue;
        backgroundColor = AppColors.statusBlueLight;
        statusTextColor = AppColors.statusBlue;
        iconData = Icons.chat_bubble_outline;
        break;
      case 'cancelado':
        iconColor = AppColors.statusRed;
        backgroundColor = AppColors.statusRedLight;
        statusTextColor = AppColors.statusRed;
        iconData = Icons.cancel_outlined;
        break;
      case 'pendiente':
      default: // Si el estado no coincide con ninguno, usa 'pendiente' como default
        iconColor = AppColors.statusOrange;
        backgroundColor = AppColors.statusOrangeLight;
        statusTextColor = AppColors.statusOrange;
        iconData = Icons.schedule;
        break;
    }

    return InkWell(
      onTap: () {
        logger.d('Tocando fila de ${quote.nombreCompleto}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          // ... el resto del widget se mantiene igual ...
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: backgroundColor,
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quote.nombreCompleto.toString(),
                    style: AppTextStyles.bodyText1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing:
                        4, // Espacio vertical si el texto pasa a otra línea
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          quote.status.toString(),
                          style: AppTextStyles.bodyText2.copyWith(
                            color: statusTextColor,
                          ),
                        ),
                      ),
                      Text(
                        '· Evento: ${quote.fechaEvento}',
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(
                  '${AppRoutes.COTIZACION_DETAIL.replaceAll(':id', '')}${quote.id}',
                );
              },
              child: const Text('Ver', style: AppTextStyles.link),
            ),
          ],
        ),
      ),
    );
  }
}
