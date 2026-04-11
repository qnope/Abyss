import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../domain/map/cell_content_type.dart';
import '../../../domain/map/map_cell.dart';
import '../../extensions/cell_content_type_extensions.dart';
import '../../extensions/terrain_type_extensions.dart';
import '../../theme/abyss_colors.dart';

const cellSize = 48.0;
const _contentSize = 28.0;

class MapCellWidget extends StatelessWidget {
  final MapCell cell;
  final bool isRevealed;
  final bool isCollectedByOther;
  final bool isBase;
  final bool hasPendingExploration;
  final bool isCapturedTransitionBase;
  final VoidCallback? onTap;

  const MapCellWidget({
    super.key,
    required this.cell,
    required this.isRevealed,
    this.isCollectedByOther = false,
    this.isBase = false,
    this.hasPendingExploration = false,
    this.isCapturedTransitionBase = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: Stack(
          children: [
            _background(),
            _terrainLayer(),
            if (isRevealed) _contentLayer(),
            if (hasPendingExploration) _explorationMarker(),
            if (!isRevealed) _fogOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _background() => Container(color: AbyssColors.abyssBlack);

  Widget _terrainLayer() => SvgPicture.asset(
        cell.terrain.svgPath,
        width: cellSize,
        height: cellSize,
      );

  Widget _contentLayer() {
    if (cell.content == CellContentType.passage) {
      return _passageOverlay();
    }
    if (cell.content == CellContentType.transitionBase) {
      return _transitionBaseOverlay();
    }
    final path = _contentSvgPath;
    if (path == null) return const SizedBox.shrink();
    final icon = Center(
      child: SvgPicture.asset(path, width: _contentSize, height: _contentSize),
    );
    if (cell.collectedBy != null) {
      return Opacity(opacity: 0.3, child: icon);
    }
    return icon;
  }

  Widget _passageOverlay() {
    return Center(
      child: Container(
        width: _contentSize,
        height: _contentSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AbyssColors.biolumPurple.withValues(alpha: 0.3),
          boxShadow: [
            BoxShadow(
              color: AbyssColors.biolumPurple.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _transitionBaseOverlay() {
    final glowColor = isCapturedTransitionBase
        ? AbyssColors.biolumCyan
        : AbyssColors.error;
    return Center(
      child: Container(
        width: _contentSize,
        height: _contentSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.6),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.electric_bolt,
          color: glowColor,
          size: _contentSize,
        ),
      ),
    );
  }

  String? get _contentSvgPath {
    if (isBase) return 'assets/icons/map_content/player_base.svg';
    if (cell.content == CellContentType.monsterLair) {
      return cell.lair?.difficulty.svgPath;
    }
    return cell.content.svgPath;
  }

  Widget _explorationMarker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AbyssColors.biolumCyan,
          width: 2,
        ),
      ),
    );
  }

  Widget _fogOverlay() {
    return Container(
      color: AbyssColors.abyssBlack.withValues(alpha: 0.7),
    );
  }
}
