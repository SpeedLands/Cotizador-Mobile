import 'package:flutter/material.dart';

class ActiveFiltersDisplay extends StatelessWidget {
  const ActiveFiltersDisplay({
    required this.filters,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.spacing = 8.0,
    this.runSpacing = 4.0,
  });
  final List<ActiveFilter> filters;
  final EdgeInsets padding;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: filters
            .map(
              (filter) =>
                  Chip(label: Text(filter.label), onDeleted: filter.onRemove),
            )
            .toList(),
      ),
    );
  }
}

class ActiveFilter {
  const ActiveFilter({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;
}
