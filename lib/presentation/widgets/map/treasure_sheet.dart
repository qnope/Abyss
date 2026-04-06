import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/resource/resource_type.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/resource_type_extensions.dart';
import '../../theme/abyss_colors.dart';

void showTreasureSheet(
  BuildContext context, {
  required int targetX,
  required int targetY,
  required CellContentType contentType,
  ResourceType? bonusResourceType,
  int? bonusAmount,
  required VoidCallback onCollect,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TreasureSheet(
      targetX: targetX,
      targetY: targetY,
      contentType: contentType,
      bonusResourceType: bonusResourceType,
      bonusAmount: bonusAmount,
      onCollect: onCollect,
    ),
  );
}

class _TreasureSheet extends StatelessWidget {
  final int targetX;
  final int targetY;
  final CellContentType contentType;
  final ResourceType? bonusResourceType;
  final int? bonusAmount;
  final VoidCallback onCollect;

  const _TreasureSheet({
    required this.targetX,
    required this.targetY,
    required this.contentType,
    this.bonusResourceType,
    this.bonusAmount,
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
          if (contentType == CellContentType.resourceBonus) ...[
            _infoRow(textTheme, 'Type', bonusResourceType?.displayName ?? ''),
            const SizedBox(height: 8),
            _infoRow(textTheme, 'Montant', '${bonusAmount ?? 0}'),
          ],
          if (contentType == CellContentType.ruins)
            Text(
              'Ressources aléatoires et perles',
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
}
