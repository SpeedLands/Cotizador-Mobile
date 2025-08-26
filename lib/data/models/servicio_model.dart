// En lib/data/models/servicio_model.dart

class Servicio {
  Servicio({
    required this.id,
    required this.nombre,
    required this.precioBase,
    required this.tipoCobro,
    required this.minPersonas,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
    id: int.parse(
      json['id']?.toString() ?? '0',
    ), // Añadimos protección contra nulos
    nombre: json['nombre'].toString(), // Protección para strings
    precioBase: json['precio_base']?.toString() ?? '0.0',
    tipoCobro: json['tipo_cobro'].toString(),

    // --- ¡CORRECCIÓN DEFINITIVA AQUÍ! ---
    // Usamos double.tryParse, que devuelve null si falla, en lugar de un error.
    // Luego, usamos el operador '??' para asignar 0 si el resultado es null.
    minPersonas: (double.tryParse(json['min_personas']?.toString() ?? '') ?? 0)
        .toInt(),
  );
  final int id;
  final String nombre;
  final String precioBase;
  final String tipoCobro;
  final int minPersonas;
}
