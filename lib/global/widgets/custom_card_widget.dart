import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.padding = const EdgeInsets.all(16),
    this.showDivider = true,
    this.borderRadius = 12.0,
    this.backgroundColor,
    this.shadowColor,
  });
  final String? title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsets padding;
  final bool showDivider;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: backgroundColor ?? AppColors.background,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? AppColors.grey).withValues(alpha: 0.1),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null || actions != null)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Expanded(child: Text(title!, style: AppTextStyles.headline3)),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        if (showDivider && (title != null || actions != null)) const Divider(),
        Padding(padding: padding, child: child),
      ],
    ),
  );
}
