import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';

/// One line of a map sheet: a dim label on the left, its bold value on
/// the right.
class SheetInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const SheetInfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: style?.copyWith(color: AbyssColors.onSurfaceDim),
          ),
        ),
        Text(
          value,
          style: style?.copyWith(
            color: AbyssColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
