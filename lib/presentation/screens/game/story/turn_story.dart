import '../../../../domain/game/game.dart';
import '../../../../domain/map/cell_content_type.dart';
import '../../../../domain/map/game_map.dart';
import '../../../../domain/map/volcanic_kernel_placer.dart';
import '../../../../domain/turn/turn_result.dart';
import '../../../../domain/volcano/kernel_garrison.dart';
import '../../../extensions/monster_lair_extensions.dart';
import '../../../widgets/map/effects/story/map_siege.dart';
import 'story_chapter.dart';
import 'turn_story_fog.dart';
import 'turn_story_snapshot.dart';

/// What the map tells at the end of a turn, before its summary: the fog
/// lifting from the cells the scouts saw, then the raids fought on the
/// base, then the wave fought on the volcano.
class TurnStory {
  final List<StoryChapter> chapters;

  const TurnStory(this.chapters);

  /// The story of the turn of [game] that ended in [result], told from
  /// what the player had [before] it.
  factory TurnStory.plan(
      Game game, TurnStorySnapshot before, TurnResult result) {
    final human = game.humanPlayer;
    return TurnStory([
      if (fogLiftChapter(game, before) case final fog?) fog,
      for (final raid in [result.raid, result.predators])
        if (raid != null)
          StoryChapter(
            level: 1,
            effect: MapSiege(
              place: (human.baseX, human.baseY),
              victory: raid.victory,
              attackerSprite: raid.wave.svgPath,
            ),
          ),
      if (result.volcano case final wave?)
        if (_kernelOf(game.levels[KernelGarrison.volcanoLevel], human.id)
            case final kernel?)
          StoryChapter(
            level: KernelGarrison.volcanoLevel,
            effect: MapSiege(
              place: kernel,
              span: VolcanicKernelPlacer.side,
              victory: wave.victory,
              attackerSprite: wave.wave.svgPath,
            ),
          ),
    ]);
  }

  /// Whether there is nothing to tell.
  bool get isEmpty => chapters.isEmpty;

  /// The volcano of [map] held by [playerId], or else the first one.
  static (int, int)? _kernelOf(GameMap? map, String playerId) {
    if (map == null) return null;
    (int, int)? first;
    for (var y = 0; y < map.height; y++) {
      for (var x = 0; x < map.width; x++) {
        final cell = map.cellAt(x, y);
        if (cell.content != CellContentType.volcanicKernel) continue;
        if (cell.collectedBy == playerId) return (x, y);
        first ??= (x, y);
      }
    }
    return first;
  }
}
