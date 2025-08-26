import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_button.dart';
import '../styles/app_text_styles.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({
    required this.title,
    required this.filterWidgets,
    required this.onApply,
    required this.onClear,
    super.key,
    this.contentPadding,
  });
  final String title;
  final List<Widget> filterWidgets;
  final VoidCallback onApply;
  final VoidCallback onClear;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      padding: (contentPadding ?? const EdgeInsets.all(16)).copyWith(
        bottom: 16.0 + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.headline2),
          const Divider(),
          ...filterWidgets,
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                onPress: () {
                  onClear();
                  Get.back();
                },
                text: 'Limpiar Filtros',
              ),
              CustomButton(
                onPress: () {
                  onApply();
                  Get.back();
                },
                text: 'Aplicar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void show({
    required String title,
    required List<Widget> filterWidgets,
    required VoidCallback onApply,
    required VoidCallback onClear,
    EdgeInsets? contentPadding,
  }) {
    Get.bottomSheet(
      FilterBottomSheet(
        title: title,
        filterWidgets: filterWidgets,
        onApply: onApply,
        onClear: onClear,
        contentPadding: contentPadding,
      ),
      isScrollControlled: true,
    );
  }
}
