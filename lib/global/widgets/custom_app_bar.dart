import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title,
    super.key,
    this.showBackButton = false,
    this.showDrawer = true,
    this.actions,
  });
  final String title;
  final bool showBackButton;
  final bool showDrawer;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => AppBar(
    title: Text(
      title,
      style: AppTextStyles.headline2.copyWith(color: AppColors.textLight),
    ),
    backgroundColor: AppColors.primary,
    elevation: 0,
    iconTheme: const IconThemeData(color: AppColors.textLight),
    actions: actions,
    automaticallyImplyLeading: showBackButton,
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
