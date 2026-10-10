import 'package:flutter/material.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../theme/abyss_colors.dart';
import '../common/raster_svg.dart';
import 'sheet_notice.dart';

void showTreasureSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required CellContentType contentType,
  required VoidCallback onCollect,
  String? notice,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TreasureSheet(
      targetX: targetX,
      targetY: targetY,
      contentType: contentType,
      onCollect: onCollect,
      notice: notice,
    ),
  );
}

class _TreasureSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final CellContentType contentType;
  final VoidCallback onCollect;

  /// Timed notice under the description, e.g. the wreck's countdown.
  final String? notice;

  const _TreasureSheet({
    required this.targetX,
    required this.targetY,
    required this.contentType,
    required this.onCollect,
    this.notice,
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
            RasterSvg(assetPath: svgPath, size: 64),
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
          if (notice != null) SheetNotice(notice!),
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
      case CellContentType.wreck:
        return 'Corail, minerai et une perle';
      case CellContentType.empty:
      case CellContentType.monsterLair:
      case CellContentType.transitionBase:
      case CellContentType.passage:
      case CellContentType.volcanicKernel:
        return '';
    }
  }
}
