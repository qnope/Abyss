import 'package:flutter/material.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/common/notice_banner.dart';
import '../../widgets/unit/unit_transfer_dialog.dart';

/// Picks the units sent down as reinforcements, arriving next turn.
class ReinforcementDialog extends StatelessWidget {
  final Map<UnitType, Unit> availableUnits;
  final int targetLevel;
  final String transitionBaseName;
  final void Function(Map<UnitType, int> selectedUnits) onConfirm;

  const ReinforcementDialog({
    super.key,
    required this.availableUnits,
    required this.targetLevel,
    required this.transitionBaseName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return UnitTransferDialog(
      title: l10n.screenReinforcementTitle(targetLevel),
      subtitle: transitionBaseName,
      notice: NoticeBanner(
        icon: Icons.info_outline,
        color: AbyssColors.biolumBlue,
        text: l10n.screenReinforcementInfo,
      ),
      availableUnits: availableUnits,
      confirmLabel: l10n.screenReinforcementConfirm,
      onConfirm: onConfirm,
    );
  }
}
