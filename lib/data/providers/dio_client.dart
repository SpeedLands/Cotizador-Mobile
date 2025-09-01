import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../../utils/logger.dart';

class DioClient {
  final AuthService _authService;

  DioClient(this._authService) : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Verificar si el token está próximo a expirar y renovarlo si es necesario
          if (_authService.isTokenExpiringSoon()) {
            logger.i('🔄 Token próximo a expirar, renovando...');
            await _authService.refreshToken();
          }

          final jwtToken = _authService.getCurrentToken();
          if (jwtToken != null) {
            options.headers['Authorization'] = 'Bearer $jwtToken';
            return handler.next(options);
          }

          final prefs = await SharedPreferences.getInstance();
          final guestToken = prefs.getString('guest_token');
          if (guestToken != null) {
            options.headers['X-Guest-Token'] = guestToken;
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            logger.w('❌ Token expirado, intentando renovar...');

            // Intentar renovar el token
            final refreshed = await _authService.refreshToken();
            if (refreshed) {
              // Reintentar la petición original con el nuevo token
              final newToken = _authService.getCurrentToken();
              if (newToken != null) {
                e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                try {
                  final response = await _dio.fetch(e.requestOptions);
                  return handler.resolve(response);
                } catch (retryError) {
                  logger.e('❌ Error al reintentar petición', error: retryError);
                  await _authService.clearTokens();
                  return handler.next(e);
                }
              }
            } else {
              // Si no se puede renovar, limpiar tokens y redirigir al login
              await _authService.clearTokens();
              logger.w('❌ No se pudo renovar el token, redirigiendo al login');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
  final Dio _dio;

  static const String _baseUrl =
      'https://pahoran.com.mx/SGC-Mapolato/public/api/v1';

  Dio get dio => _dio;
}
