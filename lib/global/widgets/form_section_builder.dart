import 'package:flutter/material.dart';

import '../styles/app_text_styles.dart';
import 'custom_dropdown_form_field.dart';
import 'custom_text_form_field.dart';

class FormSectionBuilder extends StatelessWidget {
  const FormSectionBuilder({
    required this.children,
    super.key,
    this.title,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });
  final String? title;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: AppTextStyles.headline2),
          const SizedBox(height: 16),
        ],
        ...children,
      ],
    ),
  );

  static Widget spacing({double height = 16}) => SizedBox(height: height);

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => CustomTextFormField(
    controller: controller,
    labelText: label,
    hintText: hintText,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    maxLines: maxLines,
    validator: validator,
  );

  static Widget buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) => CustomDropdownFormField<T>(
    labelText: label,
    value: value,
    items: items,
    onChanged: onChanged,
    hintText: hintText,
  );
}
