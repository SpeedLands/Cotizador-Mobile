import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/cotizacion_resumen_model.dart';
import '../../data/models/kpi_data_model.dart';
import '../../global/custom_card.dart';
import '../../global/styles/app_colors.dart';
import '../../global/styles/app_text_styles.dart';
import '../../global/widgets/custom_scaffold.dart';
import '../../global/widgets/loading_indicator.dart';
import 'dashboard_controller.dart';
import 'widgets/activity_list_item.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return CustomScaffold(
      showBackButton: true,
      showDrawer: true,
      title: 'Dashboard',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoadingIndicator();
        }
        if (controller.dashboardData.value == null) {
          return const Center(child: Text('No se pudieron cargar los datos.'));
        }
        // Si los datos están cargados, mostramos el contenido
        return _buildDashboardContent(bottomPadding);
      }),
    );
  }

  Widget _buildDashboardContent(double bottomPadding) {
    final data = controller.dashboardData.value!;
    return RefreshIndicator(
      onRefresh: () => controller.fetchDashboardData(),
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20.0 + bottomPadding),
        children: [
          // --- SECCIÓN DE KPIs ---
          _buildKpiGrid(data.kpis),

          // --- SECCIÓN DE COTIZACIONES RECIENTES ---
          _buildRecentQuotesSection(data.ultimasCotizaciones),
          const SizedBox(height: 24),

          _buildIngresosChart(),
          const SizedBox(height: 16),
          _buildCanalOrigenChart(),
          const SizedBox(height: 16),
          _buildTipoEventoChart(),
        ],
      ),
    );
  }

  Widget _buildKpiGrid(KpiData kpis) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 1.5,
    children: [
      StatCard(
        icon: Icons.pending_actions,
        value: kpis.pendientes.toString(),
        title: 'Pendientes',
        color: AppColors.amber,
      ),
      StatCard(
        icon: Icons.check_circle,
        value: kpis.confirmadasMes.toString(),
        title: 'Confirmadas (Mes)',
        color: AppColors.green,
      ),
      StatCard(
        icon: Icons.attach_money,
        value: '\$ ${kpis.ingresosMes}',
        title: 'Ingresos (Mes)',
        color: AppColors.blue,
      ),
      StatCard(
        icon: Icons.trending_up,
        value: '${kpis.conversionRate['tasa']}%',
        title: 'Conversión',
        color: AppColors.purple,
      ),
    ],
  );

  Widget _buildRecentQuotesSection(List<CotizacionResumen> quotes) => Padding(
    // Añadimos un padding general para separar la sección de otros elementos
    padding: const EdgeInsets.all(2),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          const Padding(
            padding: EdgeInsets.only(top: 16, left: 14),
            child: Text(
              'Actividad Reciente', // Cambiamos el título
              style: AppTextStyles.headline2,
            ),
          ),
          const Divider(),

          // Tarjeta que contiene la lista
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: quotes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay actividad reciente.'),
                  )
                : ListView.separated(
                    itemCount: quotes.length,
                    shrinkWrap: true, // Esencial dentro de una Column
                    physics:
                        const NeverScrollableScrollPhysics(), // Para que no haga scroll por sí misma
                    itemBuilder: (context, index) =>
                        // Llamamos a nuestro nuevo widget personalizado
                        ActivityListItem(quote: quotes[index]),
                    separatorBuilder: (context, index) =>
                        // Divisor con un margen a la izquierda para no tocar el ícono
                        const Divider(
                          height: 1,
                          indent: 70, // Espacio a la izquierda
                          endIndent: 16, // Espacio a la derecha
                        ),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _buildIngresosChart() {
    final barData = controller.getIngresosChartData();
    final titles = controller.getIngresosChartTitles();

    return _ChartCard(
      title: 'Ingresos por Mes',
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barData,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == meta.max) {
                            return const Text(
                              '',
                            ); // Ocultar el 0 y el valor máximo
                          }
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(12),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        // Obtenemos el nombre del mes usando el índice
                        final String mes = titles[group.x.toInt()];

                        return BarTooltipItem(
                          '$mes\n', // Primera línea: el nombre del mes
                          AppTextStyles.headline3.copyWith(
                            color: AppColors.textLight,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Ingresos: ', // Etiqueta estática
                              style: AppTextStyles.bodyText2.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '\${rod.toY.toStringAsFixed(2)}', // El valor
                              style: AppTextStyles.bodyText1.copyWith(
                                color: AppColors.mint,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanalOrigenChart() => _buildPieChartCard(
    title: 'Cotizaciones por Canal de Origen',
    pieData: controller.getCanalOrigenChartData(),
    labels: controller.getCanalOrigenChartLabels(),
  );

  Widget _buildTipoEventoChart() => _buildPieChartCard(
    title: 'Cotizaciones por Tipo de Evento',
    pieData: controller.getTipoEventoChartData(),
    labels: controller.getTipoEventoChartLabels(),
  );

  Widget _buildPieChartCard({
    required String title,
    required List<PieChartSectionData> pieData,
    required List<String> labels,
  }) {
    final List<Color> colors = DashboardController.getPieChartColors();
    return _ChartCard(
      title: title,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sections: pieData,
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      labels.length,
                      (index) => _buildLegendItem(
                        color: colors[index % colors.length],
                        text: labels[index],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(width: 16, height: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(title, style: AppTextStyles.headline3),
          ),
          const Divider(),
          child,
        ],
      ),
    ),
  );
}
