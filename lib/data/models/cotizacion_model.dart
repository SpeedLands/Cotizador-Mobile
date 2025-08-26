import 'servicio_model.dart';

class Cotizacion {
  Cotizacion({
    // Requeridos
    required this.id,
    required this.nombreCompleto,
    required this.fechaEvento,
    required this.totalEstimado,
    required this.status,
    required this.cantidadInvitados,
    required this.guestToken,
    required this.fechaCreacion,
    required this.totalBase,
    required this.costoAdicionalIa,
    required this.justificacionIa, // Opcionales
    this.whatsapp,
    this.tipoEvento,
    this.nombreEmpresa,
    this.direccionEvento,
    this.horaEvento,
    this.horarioConsumo,
    this.serviciosOtros,
    this.comoSupiste,
    this.comoSupisteOtro,
    this.mesaMantel,
    this.mesaMantelOtro,
    this.personalServicio,
    this.accesoEnchufe,
    this.dificultadMontaje,
    this.tipoConsumidores,
    this.restricciones,
    this.requisitosAdicionales,
    this.presupuesto,
    this.serviciosSeleccionados,
  });

  /// Factory constructor para crear una instancia de Cotizacion desde un mapa JSON.
  factory Cotizacion.fromJson(Map<String, dynamic> json) {
    // Manejar la lista de servicios, que puede no estar siempre presente
    var serviciosList = <Servicio>[];
    if (json['servicios_seleccionados'] != null) {
      serviciosList = (json['servicios_seleccionados'] as List)
          .map((s) => Servicio.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return Cotizacion(
      // Campos requeridos
      id: int.parse(json['id']?.toString() ?? '0'),
      guestToken: json['guest_token']?.toString() ?? '',
      nombreCompleto: json['nombre_completo']?.toString() ?? '',
      fechaEvento: json['fecha_evento']?.toString() ?? '',
      fechaCreacion: json['fecha_creacion']?.toString() ?? '',
      totalEstimado:
          double.tryParse(json['total_estimado']?.toString() ?? '0.0') ?? 0.0,
      totalBase:
          double.tryParse(json['total_base']?.toString() ?? '0.0') ?? 0.0,
      costoAdicionalIa:
          double.tryParse(json['costo_adicional_ia']?.toString() ?? '0.0') ??
          0.0,
      justificacionIa: json['justificacion_ia']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      cantidadInvitados:
          (double.tryParse(json['cantidad_invitados']?.toString() ?? '') ?? 0)
              .toInt(),
      // Campos opcionales (el JSON puede no tenerlos, por eso accedemos con `json['campo']` que devuelve null si no existe)
      whatsapp: json['whatsapp'].toString(),
      tipoEvento: json['tipo_evento']?.toString(),
      nombreEmpresa: json['nombre_empresa'].toString(),
      direccionEvento: json['direccion_evento']?.toString(),
      horaEvento: json['hora_evento'].toString(),
      horarioConsumo: json['horario_consumo'].toString(),
      serviciosOtros: json['servicios_otros'].toString(),
      comoSupiste: json['como_supiste'].toString(),
      comoSupisteOtro: json['como_supiste_otro'].toString(),
      mesaMantel: json['mesa_mantel'].toString(),
      mesaMantelOtro: json['mesa_mantel_otro'].toString(),
      personalServicio: json['personal_servicio'].toString(),
      accesoEnchufe: json['acceso_enchufe']?.toString(),
      dificultadMontaje: json['dificultad_montaje']?.toString(),
      tipoConsumidores: json['tipo_consumidores']?.toString(),
      restricciones: json['restricciones']?.toString(),
      requisitosAdicionales: json['requisitos_adicionales']?.toString(),
      presupuesto: json['presupuesto'].toString(),

      // Lista de servicios
      serviciosSeleccionados: serviciosList,
    );
  }
  // --- Campos Principales (Siempre presentes) ---
  final int id;
  final String nombreCompleto;
  final String fechaEvento;
  final double totalEstimado;
  final String status;
  final int cantidadInvitados;

  // --- Campos Opcionales (Pueden ser nulos) ---
  final String? whatsapp;
  final String? tipoEvento;
  final String? nombreEmpresa;
  final String? direccionEvento;
  final String? horaEvento;
  final String? horarioConsumo;
  final String? serviciosOtros;
  final String? comoSupiste;
  final String? comoSupisteOtro;
  final String? mesaMantel;
  final String? mesaMantelOtro;
  final String? personalServicio;
  final String? accesoEnchufe;
  final String? dificultadMontaje;
  final String? tipoConsumidores;
  final String? restricciones;
  final String? requisitosAdicionales;
  final String? presupuesto;
  final String guestToken;
  final String fechaCreacion;
  final double totalBase;
  final double costoAdicionalIa;
  final String justificacionIa;

  // --- Campos Relacionados ---
  final List<Servicio>? serviciosSeleccionados;
}
