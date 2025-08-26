import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  DioClient() : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    // --- ¡AQUÍ ESTÁ LA MAGIA: EL INTERCEPTOR! ---
    _dio.interceptors.add(
      InterceptorsWrapper(
        // Se ejecuta ANTES de cada petición
        onRequest: (options, handler) async {
          // Obtenemos la instancia de SharedPreferences
          final prefs = await SharedPreferences.getInstance();

          // Buscamos el token JWT (para admins)
          final jwtToken = prefs.getString('jwt_token');
          if (jwtToken != null) {
            options.headers['Authorization'] = 'Bearer $jwtToken';
            return handler.next(options); // Continuar con la petición
          }

          // Si no hay JWT, buscamos el guest_token (para invitados)
          final guestToken = prefs.getString('guest_token');
          if (guestToken != null) {
            options.headers['X-Guest-Token'] = guestToken;
          }

          return handler.next(options); // Continuar con la petición
        },

        // Se ejecuta si hay un error en la petición
        onError: (DioException e, handler) {
          // Ejemplo: Si el error es 401 (No autorizado), podríamos
          // borrar el token y redirigir al login.
          if (e.response?.statusCode == 401) {
            // Lógica para desloguear al usuario
          }
          return handler.next(e); // Continuar con el error
        },
      ),
    );
  }
  final Dio _dio;

  // URL base de tu API
  static const String _baseUrl =
      'https://pahoran.com.mx/SGC-Mapolato/public/api/v1';

  // Getter para poder usar la instancia de Dio desde nuestro ApiService
  Dio get dio => _dio;
}
