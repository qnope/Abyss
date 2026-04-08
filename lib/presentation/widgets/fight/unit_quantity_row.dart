import 'package:flutter/material.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../unit/unit_icon.dart';

class UnitQuantityRow extends StatelessWidget {
  final UnitType type;
  final int stock;
  final int value;
  final ValueChanged<int> onChanged;

  const UnitQuantityRow({
    super.key,
    required this.type,
    required this.stock,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canDecrement = value > 0;
    final canIncrement = value < stock;
    final sliderMax = stock.toDouble();
    final sliderValue = value.toDouble().clamp(0.0, sliderMax);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 64,
          child: Row(
            children: [
              UnitIcon(type: type, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: textTheme.titleMedium?.copyWith(
                        color: type.color,
                      ),
                    ),
                    Text(
                      'Stock: $stock',
                      style: textTheme.bodySmall?.copyWith(
                        color: AbyssColors.onSurfaceDim,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: canDecrement ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: AbyssColors.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: canIncrement ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Slider(
            min: 0,
            max: sliderMax,
            divisions: stock,
            value: sliderValue,
            onChanged: (double v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
