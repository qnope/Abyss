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

/// Picks the units that go down for good through a captured base.
class DescentDialog extends StatelessWidget {
  final Map<UnitType, Unit> availableUnits;
  final int targetLevel;
  final String transitionBaseName;

  /// The kind of post the units go through, drawn beside the title.
  final TransitionBaseType? baseType;
  final void Function(Map<UnitType, int> selectedUnits) onConfirm;

  const DescentDialog({
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
      title: l10n.screenDescentTitle(targetLevel),
      subtitle: transitionBaseName,
      illustration: baseType?.svgPathFor(PostHolder.human),
      notice: NoticeBanner(
        icon: Icons.warning_amber,
        color: AbyssColors.warning,
        text: l10n.screenDescentWarning,
      ),
      availableUnits: availableUnits,
      confirmLabel: l10n.screenDescentConfirm,
      onConfirm: onConfirm,
    );
  }
}
