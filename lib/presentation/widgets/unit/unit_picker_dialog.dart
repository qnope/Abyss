import 'package:flutter/material.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../theme/abyss_colors.dart';
import 'unit_transfer_dialog.dart';

/// Dialog that picks how many units of each type to move, out of
/// [availableUnits]. Returns the non-zero picks, or `null` when cancelled.
Future<Map<UnitType, int>?> showUnitPickerDialog(
  BuildContext context, {
  required String title,
  required Map<UnitType, Unit> availableUnits,
  required String confirmLabel,
  String? info,
}) =>
    showDialog<Map<UnitType, int>>(
      context: context,
      builder: (ctx) => UnitTransferDialog(
        title: title,
        availableUnits: availableUnits,
        confirmLabel: (total) => '$confirmLabel ($total)',
        notice: info == null
            ? null
            : Text(
                info,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: AbyssColors.onSurfaceDim,
                ),
              ),
      ),
    );
