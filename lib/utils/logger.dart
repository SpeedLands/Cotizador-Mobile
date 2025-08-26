// lib/utils/logger.dart

import 'package:flutter/foundation.dart'; // ¡Importante para kDebugMode!
import 'package:logger/logger.dart';

// Creamos una instancia global del logger
final logger = Logger(
  // Establecemos el nivel de log. En modo debug, muestra todo.
  // En modo release, no muestra nada por debajo de 'warning'.
  level: kDebugMode ? Level.trace : Level.warning,

  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.none,
  ),
);
