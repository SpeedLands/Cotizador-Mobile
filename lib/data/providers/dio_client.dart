import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  DioClient() : _dio = Dio(BaseOptions(baseUrl: _baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();

          final jwtToken = prefs.getString('jwt_token');
          if (jwtToken != null) {
            options.headers['Authorization'] = 'Bearer $jwtToken';
            return handler.next(options);
          }

          final guestToken = prefs.getString('guest_token');
          if (guestToken != null) {
            options.headers['X-Guest-Token'] = guestToken;
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {}
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
