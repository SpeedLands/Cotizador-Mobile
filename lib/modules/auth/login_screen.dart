import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global/custom_button.dart';
import '../../global/styles/app_colors.dart';
import '../../global/widgets/base_screen.dart';
import '../../utils/form_helper.dart';
import 'auth_controller.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BaseScreen(
    title: 'Acceso de Administrador',
    showDrawer: false,
    showBackButton: false,
    isLoading: controller.isLoading,
    contentBuilder: (context) => Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset('assets/logo_name.png', height: 80),
            const SizedBox(height: 40),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 32),
            _buildLoginButton(),
          ],
        ),
      ),
    ),
  );

  Widget _buildEmailField() => FormHelper.buildTextField(
    controller: controller.emailController,
    label: 'Correo Electrónico',
    keyboardType: TextInputType.emailAddress,
    hintText: 'ejemplo@correo.com',
  );

  Widget _buildPasswordField() => FormHelper.buildTextField(
    controller: controller.passwordController,
    label: 'Contraseña',
    readOnly: false,
    hintText: '********',
  );

  Widget _buildLoginButton() => CustomButton(
    color: AppColors.green,
    onPress: controller.isLoading.value ? null : () => controller.login(),
    text: 'Iniciar Sesión',
  );
}
