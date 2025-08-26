import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/usuario_model.dart';
import '../../data/services/api_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/logger.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isAuthenticated = false.obs;
  var usuario = Rx<Usuario?>(null);

  final emailController = TextEditingController(text: 'admin@mapolato.com');
  final passwordController = TextEditingController(text: 'admin123');

  var isLoading = false.obs;
  var passwordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      isAuthenticated.value = true;
    } else {
      isAuthenticated.value = false;
    }
  }

  Future<void> login() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      final prefs = await SharedPreferences.getInstance();

      final responseBody = response;
      final token = responseBody['token'] as String;
      final userData = responseBody['user'] as Map<String, dynamic>;

      await prefs.setString('jwt_token', token);
      usuario.value = Usuario.fromJson(userData);
      isAuthenticated.value = true;

      logger.i(
        '✅ Login exitoso para ${usuario.value?.email}. Navegando al dashboard.',
      );
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } on DioException catch (e) {
      String errorMessage = 'Ocurrió un error inesperado. Inténtalo de nuevo.';

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
      Get.snackbar('Error de Login', errorMessage);
    } on Exception catch (e, stackTrace) {
      logger.f(
        'Error crítico no controlado durante el login.',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Error Crítico',
        'Ha ocurrido un problema inesperado en la aplicación.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    usuario.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.COTIZADOR);
  }
}
