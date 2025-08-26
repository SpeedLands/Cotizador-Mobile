import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/services/api_service.dart';
import 'firebase_options.dart';
import 'modules/auth/auth_binding.dart';
import 'modules/auth/auth_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final jwtToken = prefs.getString('jwt_token');
  final initialRoute = jwtToken != null
      ? AppRoutes.DASHBOARD
      : AppRoutes.COTIZADOR;

  Get
    ..put(ApiService(), permanent: true)
    ..put(AuthController(), permanent: true);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapolato App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      locale: const Locale('es', 'MX'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        PhoneFieldLocalization.delegate,
      ],
      supportedLocales: const [Locale('es', 'MX')],
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      initialBinding: AuthBinding(),
    ),
  );
}
