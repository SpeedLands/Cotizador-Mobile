import 'package:flutter/material.dart';
import 'styles/app_colors.dart';
import 'styles/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  /// Constructor del widget.
  const CustomButton({
    required this.text,
    required this.onPress,
    super.key,
    this.color = AppColors.primary,
  });

  /// El texto que se mostrará dentro del botón.
  final String text;
  final Color color;

  /// La función que se ejecutará cuando se presione el botón.
  /// Si es nulo, el botón aparecerá deshabilitado.
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    final isDark = color.computeLuminance() < 0.5;
    // Usamos ElevatedButton por su versatilidad y efectos de material design.
    return ElevatedButton(
      onPressed: onPress,
      style: ElevatedButton.styleFrom(
        // Color de fondo del botón (extraído de tu imagen).
        backgroundColor: color,

        // Color del texto y del efecto "ripple" (onda al presionar).
        // Usamos un color oscuro para el texto, como en la imagen.
        foregroundColor: isDark ? AppColors.textLight : AppColors.textDark,

        // Forma del botón con bordes redondeados.
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        // Relleno interno para darle espacio al texto.
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),

        // Elevación (sombra) del botón.
        // Un valor bajo para un look moderno.
        elevation: 2,

        // Estilo del texto.
        textStyle: AppTextStyles.button,
      ),
      // El hijo del botón es el texto, que convertimos a mayúsculas.
      child: Text(text.toUpperCase()),
    );
  }
}
