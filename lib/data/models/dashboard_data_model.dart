import 'cotizacion_resumen_model.dart';
import 'kpi_data_model.dart';

class DashboardData {
  DashboardData({
    required this.kpis,
    required this.ultimasCotizaciones,
    required this.graficas,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    kpis: KpiData.fromJson(json['kpis'] as Map<String, dynamic>),
    ultimasCotizaciones: (json['ultimas_cotizaciones'] as List)
        .map((c) => CotizacionResumen.fromJson(c as Map<String, dynamic>))
        .toList(),
    graficas: json['graficas'] as Map<String, dynamic>,
  );
  final KpiData kpis;
  final List<CotizacionResumen> ultimasCotizaciones;
  // Los datos de las gráficas los manejaremos como un mapa por simplicidad
  final Map<String, dynamic> graficas;
}
