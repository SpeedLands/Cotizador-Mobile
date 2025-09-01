import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/logger.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final AuthService _authService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _authService = Get.find<AuthService>();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Escuchar cambios en el estado de autenticación
    _authService.authStateStream.listen((isAuthenticated) {
      if (_isInitialized) {
        _handleAuthStateChange(isAuthenticated);
      }
    });

    _isInitialized = true;
  }

  void _handleAuthStateChange(bool isAuthenticated) {
    if (!isAuthenticated) {
      // Si no está autenticado, redirigir al login
      final currentRoute = Get.currentRoute;
      if (currentRoute != AppRoutes.LOGIN &&
          currentRoute != AppRoutes.COTIZADOR) {
        logger.i('🔒 Usuario no autenticado, redirigiendo al login');
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } else {
      // Si está autenticado y está en login, redirigir al dashboard
      final currentRoute = Get.currentRoute;
      if (currentRoute == AppRoutes.LOGIN) {
        logger.i('✅ Usuario autenticado, redirigiendo al dashboard');
        Get.offAllNamed(AppRoutes.DASHBOARD);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
