import 'package:flutter/material.dart';

import '../../../domain/unit/unit_type.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'unit_icon.dart';

/// One line of an army that is only read: the unit's illustration and
/// how many of the type there are.
class UnitCountRow extends StatelessWidget {
  final UnitType type;
  final int count;

  const UnitCountRow({super.key, required this.type, required this.count});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        UnitIcon(type: type, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            type.units(context.l10n, count),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AbyssColors.onSurface),
          ),
        ),
      ],
    ),
  );
}
