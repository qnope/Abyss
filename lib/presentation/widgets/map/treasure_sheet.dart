import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../theme/abyss_colors.dart';

void showTreasureSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required CellContentType contentType,
  required VoidCallback onCollect,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TreasureSheet(
      targetX: targetX,
      targetY: targetY,
      contentType: contentType,
      onCollect: onCollect,
    ),
  );
}

class _TreasureSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final CellContentType contentType;
  final VoidCallback onCollect;

  const _TreasureSheet({
    required this.targetX,
    required this.targetY,
    required this.contentType,
    required this.onCollect,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final svgPath = contentType.svgPath;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgPath != null)
            SvgPicture.asset(svgPath, width: 64, height: 64),
          const SizedBox(height: 12),
          Text(
            'Trésor ($targetX, $targetY)',
            style: textTheme.headlineSmall?.copyWith(
              color: AbyssColors.biolumCyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AbyssColors.onSurfaceDim,
            ),
          ),
          const Divider(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onCollect();
            },
            child: const Text('Collecter le trésor'),
          ),
        ],
      ),
    );
  }

  String get _description {
    switch (contentType) {
      case CellContentType.resourceBonus:
        return 'Algues, corail et minerai';
      case CellContentType.ruins:
        return 'Corail, minerai et perles';
      case CellContentType.empty:
      case CellContentType.monsterLair:
      case CellContentType.transitionBase:
      case CellContentType.passage:
        return '';
    }
  }
}
