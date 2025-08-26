class KpiData {
  KpiData({
    required this.pendientes,
    required this.confirmadasMes,
    required this.ingresosMes,
    required this.conversionRate,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) => KpiData(
    pendientes: json['pendientes'] as int,
    confirmadasMes: json['confirmadas_mes'] as int,
    ingresosMes: json['ingresos_mes'].toString(), // Aseguramos que sea String
    conversionRate: json['conversion_rate'] as Map<String, dynamic>,
  );
  final int pendientes;
  final int confirmadasMes;
  final String ingresosMes;
  // Podríamos crear otro modelo para conversion_rate, pero por simplicidad lo dejamos como un mapa
  final Map<String, dynamic> conversionRate;
}
