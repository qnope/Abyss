import 'package:flutter/material.dart';

import '../../theme/abyss_colors.dart';
import 'sheet_notice.dart';

void showExplorationSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required int scoutCount,
  required int revealSide,
  required bool isEligible,
  required VoidCallback onConfirm,
  String? notice,
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

  const _ExplorationSheet({
    required this.targetX,
    required this.targetY,
    required this.scoutCount,
    required this.revealSide,
    required this.isEligible,
    required this.onConfirm,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final side = revealSide;

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
            'Explorer ($targetX, $targetY)',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          if (notice != null) SheetNotice(notice!),
          const SizedBox(height: 16),
          _infoRow(textTheme, 'Co\u00fbt', '1 \u00e9claireur'),
          const SizedBox(height: 8),
          _infoRow(
            textTheme,
            '\u00c9claireurs disponibles',
            '$scoutCount',
          ),
          const SizedBox(height: 8),
          _infoRow(
            textTheme,
            'Zone r\u00e9v\u00e9l\u00e9e',
            '$side\u00d7$side cellules',
          ),
          const Divider(height: 24),
          _actionSection(context, textTheme),
        ],
      ),
    );
  }

  Widget _infoRow(TextTheme textTheme, String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: AbyssColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _actionSection(BuildContext context, TextTheme textTheme) {
    if (scoutCount <= 0) {
      return _disabledAction(textTheme, 'Aucun \u00e9claireur disponible');
    }
    if (!isEligible) {
      return _disabledAction(textTheme, 'Cellule non \u00e9ligible');
    }
    return _sendButton(context);
  }

  Widget _disabledAction(TextTheme textTheme, String message) {
    return Column(
      children: [
        Text(
          message,
          style: textTheme.bodyMedium?.copyWith(color: AbyssColors.warning),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: null,
          child: const Text('Envoyer'),
        ),
      ],
    );
  }

  Widget _sendButton(BuildContext context) {
    return FilledButton(
      onPressed: () {
        Navigator.pop(context);
        onConfirm();
      },
      child: const Text('Envoyer'),
    );
  }
}
