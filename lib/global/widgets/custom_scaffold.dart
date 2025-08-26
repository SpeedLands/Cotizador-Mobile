import 'package:flutter/material.dart';
import '../app_drawer.dart';
import 'custom_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    required this.title,
    required this.body,
    super.key,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = false,
    this.showDrawer = true,
  });
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final bool showBackButton;
  final bool showDrawer;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(
      title: title,
      actions: actions,
      showBackButton: showBackButton,
      showDrawer: showDrawer,
    ),
    drawer: showDrawer ? const AppDrawer() : null,
    body: body,
    floatingActionButton: floatingActionButton,
  );
}
