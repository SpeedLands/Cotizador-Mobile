class CotizacionResumen {
  CotizacionResumen({
    required this.id,
    required this.nombreCompleto,
    required this.fechaEvento,
    required this.status,
  });

  factory CotizacionResumen.fromJson(Map<String, dynamic> json) =>
      CotizacionResumen(
        id: int.parse(json['id'].toString()), // El ID puede venir como String
        nombreCompleto: json['nombre_completo'].toString(),
        fechaEvento: json['fecha_evento'].toString(),
        status: json['status'].toString(),
      );
  final int id;
  final String nombreCompleto;
  final String fechaEvento;
  final String status;
}
