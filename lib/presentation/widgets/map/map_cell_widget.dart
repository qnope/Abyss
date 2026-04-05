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
  final bool isBase;
  final bool hasPendingExploration;
  final VoidCallback? onTap;

  const MapCellWidget({
    super.key,
    required this.cell,
    this.isBase = false,
    this.hasPendingExploration = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: cellSize,
        height: cellSize,
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              _background(),
              _terrainAndContentLayer(),
              if (hasPendingExploration) _explorationMarker(),
              if (!cell.isRevealed) _fogOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _terrainAndContentLayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SvgPicture.asset(
          cell.terrain.svgPath,
          width: cellSize,
          height: cellSize,
          cacheColorFilter: true,
        ),
        if (cell.isRevealed) _contentLayer(),
      ],
    );
  }

  Widget _background() {
    return Container(color: AbyssColors.abyssBlack);
  }

  Widget _contentLayer() {
    final path = _contentSvgPath;
    if (path == null) return const SizedBox.shrink();
    return Center(
      child: SvgPicture.asset(
        path,
        width: _contentSize,
        height: _contentSize,
        cacheColorFilter: true,
      ),
    );
  }

  String? get _contentSvgPath {
    if (isBase) return 'assets/icons/map_content/player_base.svg';
    if (cell.content == CellContentType.monsterLair) {
      return cell.monsterDifficulty?.svgPath;
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
