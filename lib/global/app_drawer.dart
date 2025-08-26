import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

import '../../routes/app_routes.dart';
import '../modules/auth/auth_controller.dart';
import 'styles/app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Center(
              child: RiveAnimation.asset(
                'assets/rive/logo.riv', // Asegúrate de que esta ruta sea correcta
                fit: BoxFit.contain, // Ajusta cómo se escala la animación
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onTap: () => Get.offAllNamed(AppRoutes.DASHBOARD),
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            text: 'Cotizaciones',
            onTap: () => Get.offAllNamed(
              AppRoutes.COTIZACIONES_LIST,
            ), // Define esta ruta
          ),
          _buildDrawerItem(
            icon: Icons.build,
            text: 'Servicios',
            onTap: () => Get.offAllNamed(AppRoutes.SERVICES_LIST),
          ),
          _buildDrawerItem(
            icon: Icons.calendar_today,
            text: 'Calendario',
            onTap: () => Get.offAllNamed(AppRoutes.CALENDARIO),
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            text: 'Notificaciones',
            onTap: () => Get.offAllNamed(AppRoutes.NOTIFICATIONS),
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            text: 'Cerrar Sesión',
            onTap: authController.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) => ListTile(leading: Icon(icon), title: Text(text), onTap: onTap);
}
