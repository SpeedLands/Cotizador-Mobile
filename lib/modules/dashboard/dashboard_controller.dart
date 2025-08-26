import 'dart:async';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/dashboard_data_model.dart';
import '../../data/services/api_service.dart';
import '../../global/styles/app_colors.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Estado para la UI
  var isLoading = true.obs;
  var dashboardData = Rx<DashboardData?>(null);

  static List<Color> getPieChartColors() => const [
    AppColors.purple,
    AppColors.teal,
    AppColors.pink,
    AppColors.amber,
    AppColors.green,
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  /// Obtiene los datos del dashboard desde la API.
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final data = await _apiService.getDashboardData();
      dashboardData.value = data;
    } on TimeoutException {
      Get.snackbar(
        'Error',
        'Tiempo de espera agotado. Por favor, inténtalo de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on SocketException {
      Get.snackbar(
        'Error',
        'Error de conexión. Verifica tu conexión a internet.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on Exception catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los datos del dashboard. ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<BarChartGroupData> getIngresosChartData() {
    if (dashboardData.value == null) {
      return [];
    }

    // --- CORRECCIÓN 1: Leemos el MAPA, no una lista ---
    final Map<String, dynamic> ingresosData =
        dashboardData.value!.graficas['ingresos_ultimos_meses']
            as Map<String, dynamic>? ??
        {};
    if (ingresosData.isEmpty) {
      return [];
    }

    final List<dynamic> data = ingresosData['data'] as List<dynamic>? ?? [];
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < data.length; i++) {
      final total = (data[i] as num)
          .toDouble(); // Hacemos un cast seguro a double

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: total,
              borderSide: const BorderSide(color: AppColors.primary),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.5),
                ],
              ),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  /// Obtiene los títulos (meses) para el eje X de la gráfica de ingresos.
  List<String> getIngresosChartTitles() {
    if (dashboardData.value == null) {
      return [];
    }

    // --- CORRECCIÓN 2: Leemos la lista 'labels' del MAPA ---
    final Map<String, dynamic> ingresosData =
        dashboardData.value!.graficas['ingresos_ultimos_meses']
            as Map<String, dynamic>? ??
        {};
    if (ingresosData.isEmpty) {
      return [];
    }

    final List<dynamic> labels = ingresosData['labels'] as List<dynamic>? ?? [];
    return labels.map((label) => label.toString()).toList();
  }

  /// Prepara los datos para la gráfica de pie de canales de origen.
  List<PieChartSectionData> getCanalOrigenChartData() =>
      _getPieChartData('por_canal_origen');

  // --- ¡NUEVO MÉTODO DE AYUDA PARA LA LEYENDA! ---
  /// Obtiene los labels para la leyenda de la gráfica de pie.
  List<String> getCanalOrigenChartLabels() {
    final Map<String, dynamic> canalesData =
        dashboardData.value!.graficas['por_canal_origen']
            as Map<String, dynamic>? ??
        {};
    if (canalesData.isEmpty) {
      return [];
    }
    final List<dynamic> labels = canalesData['labels'] as List<dynamic>? ?? [];
    return labels.map((label) => label.toString()).toList();
  }

  List<PieChartSectionData> getTipoEventoChartData() =>
      _getPieChartData('por_tipo_evento');

  List<String> getTipoEventoChartLabels() {
    final Map<String, dynamic> canalesData =
        dashboardData.value!.graficas['por_tipo_evento']
            as Map<String, dynamic>? ??
        {};
    if (canalesData.isEmpty) {
      return [];
    }
    final List<dynamic> labels = canalesData['labels'] as List<dynamic>? ?? [];
    return labels.map((label) => label.toString()).toList();
  }

  List<PieChartSectionData> _getPieChartData(String graphKey) {
    if (dashboardData.value == null) {
      return [];
    }

    final Map<String, dynamic> graphData =
        dashboardData.value!.graficas[graphKey] as Map<String, dynamic>? ?? {};
    if (graphData.isEmpty) {
      return [];
    }

    final List<dynamic> data = graphData['data'] as List<dynamic>? ?? [];
    if (data.isEmpty) {
      return [];
    }

    final double total = data.fold(0, (sum, item) => sum + (item as num));
    if (total == 0) {
      return []; // Evitar división por cero
    }

    final colors = getPieChartColors();
    final List<PieChartSectionData> sections = [];
    for (int i = 0; i < data.length; i++) {
      final valor = (data[i] as num).toDouble();
      final porcentaje = (valor / total) * 100;

      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: valor,
          title: '${porcentaje.toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      );
    }
    return sections;
  }
}
