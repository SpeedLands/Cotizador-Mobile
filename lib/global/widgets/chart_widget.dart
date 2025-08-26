import 'package:flutter/material.dart';
import '../styles/app_text_styles.dart';
import 'custom_card_widget.dart';

class ChartWidget extends StatelessWidget {
  const ChartWidget({
    required this.title,
    required this.chart,
    super.key,
    this.legend,
    this.padding = const EdgeInsets.all(16),
  });
  final String title;
  final Widget chart;
  final List<Widget>? legend;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CustomCardWidget(
    title: title,
    child: Padding(
      padding: padding,
      child: Column(
        children: [
          chart,
          if (legend != null) ...[const SizedBox(height: 16), ...legend!],
        ],
      ),
    ),
  );

  static Widget buildLegendItem({
    required Color color,
    required String text,
    EdgeInsets padding = const EdgeInsets.symmetric(vertical: 4),
  }) => Padding(
    padding: padding,
    child: Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyText2,
          ),
        ),
      ],
    ),
  );
}
