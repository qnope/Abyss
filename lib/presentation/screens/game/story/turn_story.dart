import '../../../../domain/game/game.dart';
import '../../../../domain/map/volcanic_kernel_placer.dart';
import '../../../../domain/turn/turn_result.dart';
import '../../../../domain/volcano/kernel_garrison.dart';
import '../../../extensions/monster_lair_extensions.dart';
import '../../../widgets/map/effects/story/map_siege.dart';
import '../../../widgets/map/effects/strike/strike_round.dart';
import 'attack_chapter.dart';
import 'story_chapter.dart';
import 'story_places.dart';
import 'turn_story_fog.dart';
import 'turn_story_snapshot.dart';

/// What the map tells at the end of a turn, before its summary: the fog
/// lifting from the cells the scouts saw, then the raids fought on the
/// base, then the wave fought on the volcano, then the attacks of the
/// factions (and of the guardians) on the human, as they were fought.
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
              rounds: roundsOf(raid.fight),
            ),
          ),
      if (result.volcano case final wave?)
        if (StoryPlaces.kernelOf(
                game.levels[KernelGarrison.volcanoLevel], human.id)
            case final kernel?)
          StoryChapter(
            level: KernelGarrison.volcanoLevel,
            effect: MapSiege(
              place: kernel,
              span: VolcanicKernelPlacer.side,
              victory: wave.victory,
              attackerSprite: wave.wave.svgPath,
              rounds: roundsOf(wave.fight),
            ),
          ),
      for (final attack in result.attacks)
        if (attackChapter(game, attack) case final chapter?) chapter,
    ]);
  }

  /// Whether there is nothing to tell.
  bool get isEmpty => chapters.isEmpty;
}
