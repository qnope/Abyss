import 'package:flutter/material.dart';
import '../../../domain/map/post_holder.dart';
import '../../../domain/map/transition_base_type.dart';
import '../../../domain/unit/unit.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/post_holder_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import '../../widgets/common/notice_banner.dart';
import '../../widgets/unit/unit_transfer_dialog.dart';

/// Picks the units sent down as reinforcements, arriving next turn.
class ReinforcementDialog extends StatelessWidget {
  final Map<UnitType, Unit> availableUnits;
  final int targetLevel;
  final String transitionBaseName;

  /// The kind of post the units go through, drawn beside the title.
  final TransitionBaseType? baseType;
  final void Function(Map<UnitType, int> selectedUnits) onConfirm;

  const ReinforcementDialog({
    super.key,
    required this.availableUnits,
    required this.targetLevel,
    required this.transitionBaseName,
    this.baseType,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return UnitTransferDialog(
      title: l10n.screenReinforcementTitle(targetLevel),
      subtitle: transitionBaseName,
      illustration: baseType?.svgPathFor(PostHolder.human),
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
