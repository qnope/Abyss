import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/cell_content_type.dart';
import '../../domain/map_cell.dart';
import '../extensions/cell_content_type_extensions.dart';
import '../extensions/terrain_type_extensions.dart';
import '../theme/abyss_colors.dart';

const cellSize = 48.0;
const _contentSize = 28.0;

class MapCellWidget extends StatelessWidget {
  final MapCell cell;
  final bool isBase;

  const MapCellWidget({
    super.key,
    required this.cell,
    this.isBase = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        children: [
          _background(),
          _terrainLayer(),
          if (cell.isRevealed) _contentLayer(),
          if (!cell.isRevealed) _fogOverlay(),
        ],
      ),
    );
  }

  Widget _background() {
    return Container(color: AbyssColors.abyssBlack);
  }

  Widget _terrainLayer() {
    return SvgPicture.asset(
      cell.terrain.svgPath,
      width: cellSize,
      height: cellSize,
    );
  }

  Widget _contentLayer() {
    final path = _contentSvgPath;
    if (path == null) return const SizedBox.shrink();
    return Center(
      child: SvgPicture.asset(
        path,
        width: _contentSize,
        height: _contentSize,
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

  Widget _fogOverlay() {
    return Container(
      color: AbyssColors.abyssBlack.withValues(alpha: 0.95),
    );
  }
}
