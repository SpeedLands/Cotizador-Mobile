import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/logger.dart';

class AuthService {
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  late final SharedPreferences _prefs;
  Timer? _refreshTimer;

  // Stream para notificar cambios en el estado de autenticación
  final _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _scheduleTokenRefresh();
  }

  // Guardar tokens después del login
  Future<void> saveTokens({
    required String jwtToken,
    required String refreshToken,
    required int expiresIn, // tiempo en segundos
  }) async {
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

    await _prefs.setString(_jwtTokenKey, jwtToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    await _prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());

    _scheduleTokenRefresh();
    _authStateController.add(true);

    logger.i('✅ Tokens guardados. Expira: ${expiryTime.toString()}');
  }

  // Obtener el token JWT actual
  String? getCurrentToken() => _prefs.getString(_jwtTokenKey);

  // Verificar si el token está próximo a expirar (5 minutos antes)
  bool isTokenExpiringSoon() {
    final expiryString = _prefs.getString(_tokenExpiryKey);
    if (expiryString == null) {
      return true;
    }

    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();
    final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

    return expiry.isBefore(fiveMinutesFromNow);
  }

  // Verificar si el token ha expirado
  bool isTokenExpired() {
    final expiryString = _prefs.getString(_tokenExpiryKey);
    if (expiryString == null) {
      return true;
    }

    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isAfter(expiry);
  }

  // Renovar token usando refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _prefs.getString(_refreshTokenKey);
      if (refreshToken == null) {
        logger.w('❌ No hay refresh token disponible');
        return false;
      }

      // Hacer la llamada directa a la API para renovar el token
      final dio = Dio();
      final response = await dio.post(
        'https://pahoran.com.mx/SGC-Mapolato/public/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await saveTokens(
          jwtToken: data['token'] as String,
          refreshToken: data['refresh_token'] as String,
          expiresIn: data['expires_in'] as int? ?? 3600, // 1 hora por defecto
        );

        logger.i('✅ Token renovado exitosamente');
        return true;
      }
    } on Exception catch (e) {
      logger.e('❌ Error al renovar token', error: e);
      // Si falla la renovación, limpiar tokens
      await clearTokens();
    }
    return false;
  }

  // Programar renovación automática del token
  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();

    final expiryString = _prefs.getString(_tokenExpiryKey);
    if (expiryString == null) {
      return;
    }

    final expiry = DateTime.parse(expiryString);
    final now = DateTime.now();
    final timeUntilRefresh =
        expiry.difference(now).inMilliseconds -
        const Duration(minutes: 5).inMilliseconds; // 5 min antes

    if (timeUntilRefresh > 0) {
      _refreshTimer = Timer(
        Duration(milliseconds: timeUntilRefresh),
        refreshToken,
      );

      logger.i(
        '🕐 Renovación programada en ${Duration(milliseconds: timeUntilRefresh)}',
      );
    }
  }

  // Limpiar todos los tokens
  Future<void> clearTokens() async {
    await _prefs.remove(_jwtTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);

    _refreshTimer?.cancel();
    _authStateController.add(false);

    logger.i('🗑️ Tokens limpiados');
  }

  // Verificar si el usuario está autenticado
  bool isAuthenticated() {
    final token = getCurrentToken();
    return token != null && !isTokenExpired();
  }

  void dispose() {
    _refreshTimer?.cancel();
    _authStateController.close();
  }
}
