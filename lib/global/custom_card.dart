import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'styles/app_colors.dart';
import 'styles/app_text_styles.dart';

class StatCard extends StatelessWidget {
  /// Constructor del widget.
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
  });

  /// El título que aparece en la parte superior (ej: "Cotizaciones Pendientes").
  final String title;

  /// El valor principal que se muestra en grande (ej: "1" o "$230.00").
  final String value;

  /// El icono que se mostrará en el círculo.
  final IconData icon;

  /// El color de acento para el círculo y la barra inferior.
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    // Usamos un Container con BoxDecoration para tener control total
    // sobre el borde, la sombra y el contenido.
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.textDark.withValues(alpha: 0.05),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 3), // Sombra sutil en la parte inferior
        ),
      ],
    ),
    // ClipRRect asegura que todo el contenido (incluida la barra inferior)
    // respete los bordes redondeados del Container.
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          // --- Contenido principal de la tarjeta ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Círculo con el icono
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color,
                  child: Icon(icon, color: AppColors.textLight, size: 22),
                ),
                const SizedBox(width: 16),

                // Columna con los textos
                // Expanded para que ocupe el espacio restante y evite overflows
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        title,
                        style: AppTextStyles.bodyText2.copyWith(
                          color: AppColors.grey,
                        ),
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                      const SizedBox(height: 4),
                      AutoSizeText(
                        value,
                        style: AppTextStyles.headline2,
                        maxLines: 1,
                        minFontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Barra de color inferior ---
          const Spacer(), // Empuja la barra al fondo si la tarjeta tiene altura fija
          Container(height: 4, color: color),
        ],
      ),
    ),
  );
}
