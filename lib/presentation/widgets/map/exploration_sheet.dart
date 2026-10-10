import 'package:flutter/material.dart';

import '../../../domain/action/action_failure.dart';
import '../../../domain/unit/unit_type.dart';
import '../../extensions/action_failure_extensions.dart';
import '../../extensions/unit_type_extensions.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/abyss_colors.dart';
import 'sheet_notice.dart';
import 'sheet_info_row.dart';

void showExplorationSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required int scoutCount,
  required int revealSide,
  required bool isEligible,
  required VoidCallback onConfirm,
  String? notice,
  String? refusal,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ExplorationSheet(
      targetX: targetX,
      targetY: targetY,
      scoutCount: scoutCount,
      revealSide: revealSide,
      isEligible: isEligible,
      onConfirm: onConfirm,
      notice: notice,
      refusal: refusal,
    ),
  );
}

class _ExplorationSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final int scoutCount;
  final int revealSide;
  final bool isEligible;
  final VoidCallback onConfirm;

  /// Timed notice about the target, e.g. the countdown of a wreck.
  final String? notice;

  /// Why the exploration cannot be sent now, checked before the scouts
  /// and the eligibility (e.g. a storm).
  final String? refusal;

  const _ExplorationSheet({
    required this.targetX,
    required this.targetY,
    required this.scoutCount,
    required this.revealSide,
    required this.isEligible,
    required this.onConfirm,
    this.notice,
    this.refusal,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.explore,
            size: 64,
            color: AbyssColors.biolumCyan,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.mapExploreTitle(targetX, targetY),
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          if (notice != null) SheetNotice(notice!),
          const SizedBox(height: 16),
          SheetInfoRow(l10n.mapCost, UnitType.scout.units(l10n, 1)),
          const SizedBox(height: 8),
          SheetInfoRow(l10n.mapScoutsAvailable, '$scoutCount'),
          const SizedBox(height: 8),
          SheetInfoRow(l10n.mapRevealedArea, l10n.mapAreaCells(revealSide)),
          const Divider(height: 24),
          _actionSection(context, textTheme),
        ],
      ),
    );
  }

  Widget _actionSection(BuildContext context, TextTheme textTheme) {
    final failure = scoutCount <= 0
        ? ActionFailure.noScoutAvailable
        : !isEligible
            ? ActionFailure.cellNotEligible
            : null;
    final reason = refusal ?? failure?.message(context.l10n);
    if (reason != null) return _disabledAction(context, textTheme, reason);
    return _sendButton(context);
  }

  Widget _disabledAction(
    BuildContext context,
    TextTheme textTheme,
    String message,
  ) {
    return Column(
      children: [
        Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: AbyssColors.warning),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: null, child: Text(context.l10n.commonSend)),
      ],
    );
  }

  Widget _sendButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.pop(context);
        onConfirm();
      },
      child: Text(context.l10n.commonSend),
    );
  }
}
