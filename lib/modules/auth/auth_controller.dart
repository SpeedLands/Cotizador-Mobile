import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/usuario_model.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/notification_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/logger.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  late final SharedPreferences _prefs;

  var isAuthenticated = false.obs;
  var usuario = Rx<Usuario?>(null);

  final emailController = TextEditingController(text: 'admin@mapolato.com');
  final passwordController = TextEditingController(text: 'admin123');

  var isLoading = false.obs;
  var passwordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> checkAuthStatus() async {
    isAuthenticated.value = _authService.isAuthenticated();
  }

  Future<void> login() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      await _handleLoginSuccess(response);
    } on Exception catch (e) {
      _handleLoginError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> response) async {
    final token = response['token'] as String;
    final refreshToken = response['refresh_token'] as String;
    final expiresIn = response['expires_in'] as int? ?? 3600;
    final userData = response['user'] as Map<String, dynamic>;

    // Guardar tokens usando el AuthService
    await _authService.saveTokens(
      jwtToken: token,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );

    usuario.value = Usuario.fromJson(userData);
    isAuthenticated.value = true;

    // --- LÓGICA DE SUSCRIPCIÓN A NOTIFICACIONES ---
    if (usuario.value?.isAdmin ?? false) {
      await _notificationService.subscribeToTopic('admins');
    }
    // ---------------------------------------------

    logger.i(
      '✅ Login exitoso para ${usuario.value?.email}. Navegando al dashboard.',
    );
    Get.offAllNamed(AppRoutes.DASHBOARD);
  }

  void _handleLoginError(Object e) {
    String errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';
    if (e is DioException) {
      if (e.response != null) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
          errorMessage = 'El email o la contraseña son incorrectos.';
        } else if (e.response!.statusCode! >= 500) {
          errorMessage =
              'El servidor no está disponible en este momento. Inténtalo más tarde.';
        }
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        errorMessage =
            'Error de conexión. Por favor, verifica tu acceso a internet.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage =
            'La solicitud tardó demasiado en responder. Inténtalo de nuevo.';
      }
      logger.w('Fallo de login manejado:', error: e);
    } else {
      logger.f('Error crítico no controlado durante el login.', error: e);
      errorMessage = 'Ha ocurrido un problema inesperado en la aplicación.';
    }
    Get.snackbar('Error de Login', errorMessage);
  }

  Future<void> logout() async {
    // --- LÓGICA DE DESUSCRIPCIÓN DE NOTIFICACIONES ---
    if (usuario.value?.isAdmin ?? false) {
      await _notificationService.unsubscribeFromTopic('admins');
    }
    // ------------------------------------------------

    await _authService.clearTokens();
    usuario.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.COTIZADOR);
  }
}
