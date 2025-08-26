import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_scaffold.dart';
import 'loading_indicator.dart';

class BaseScreen extends StatelessWidget {
  const BaseScreen({
    required this.title,
    required this.contentBuilder,
    super.key,
    this.showBackButton = true,
    this.showDrawer = true,
    this.actions,
    this.isLoading,
    this.onRefresh,
    this.emptyWidget,
  });
  final String title;
  final bool showBackButton;
  final bool showDrawer;
  final List<Widget>? actions;
  final Widget Function(BuildContext) contentBuilder;
  final RxBool? isLoading;
  final Future<void> Function()? onRefresh;
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) => CustomScaffold(
    showBackButton: showBackButton,
    showDrawer: showDrawer,
    title: title,
    actions: actions,
    body: isLoading != null
        ? Obx(() {
            if (isLoading!.value) {
              return const AppLoadingIndicator();
            }

            final content = contentBuilder(context);

            if (onRefresh != null) {
              return RefreshIndicator(onRefresh: onRefresh!, child: content);
            }

            return content;
          })
        : contentBuilder(context),
  );
}
