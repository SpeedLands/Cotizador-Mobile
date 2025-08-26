import 'package:flutter/material.dart';
import '../global/widgets/custom_text_form_field.dart';

class FormHelper {
  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => CustomTextFormField(
      controller: controller,
      labelText: label,
      keyboardType: keyboardType,
      hintText: hintText,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
    );

  static Widget buildSpacing({double height = 16}) => SizedBox(height: height);

  static Widget buildFormSection({
    required String title,
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 16),
  }) => Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
}
