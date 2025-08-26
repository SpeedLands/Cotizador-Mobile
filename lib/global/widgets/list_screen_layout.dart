import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../styles/app_text_styles.dart';
import 'base_screen.dart';

class ListScreenLayout<T> extends StatelessWidget {
  const ListScreenLayout({
    required this.title,
    required this.items,
    required this.isLoading,
    required this.emptyMessage,
    required this.onRefresh,
    required this.itemBuilder,
    super.key,
    this.actions,
    this.filterBuilder,
    this.headerContent,
    this.padding,
    this.showDrawer = false,
    this.showBackButton = false,
  });
  final String title;
  final RxList<T> items;
  final RxBool isLoading;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final Widget Function(T item) itemBuilder;
  final List<Widget>? actions;
  final Widget? filterBuilder;
  final Widget? headerContent;
  final EdgeInsets? padding;
  final bool showDrawer;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) => BaseScreen(
    title: title,
    actions: actions,
    isLoading: isLoading,
    onRefresh: onRefresh,
    showDrawer: showDrawer,
    showBackButton: showBackButton,
    contentBuilder: (context) => Column(
      children: [
        if (headerContent != null) headerContent!,
        if (filterBuilder != null) filterBuilder!,
        Expanded(
          child: Obx(() {
            if (items.isEmpty) {
              return Center(
                child: Text(emptyMessage, style: AppTextStyles.bodyText1),
              );
            }

            return ListView.builder(
              padding: padding ?? const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) => itemBuilder(items[index]),
            );
          }),
        ),
      ],
    ),
  );
}
