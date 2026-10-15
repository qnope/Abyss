import '../../../../../domain/action/fight_monster_result.dart';
import '../../../../../domain/map/monster_lair.dart';
import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/monster_lair_extensions.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../map_effect.dart';
import 'map_strike_run.dart';
import 'strike_geometry.dart';
import 'strike_lead.dart';
import 'strike_round.dart';

/// An army attacking the lair on [target]: a token showing its [lead]
/// unit and its [count] swims beside the lair, lunges at it once per
/// turn of the fight (its [rounds]), then the monster fades away on a
/// [victory], or the token retreats.
class MapStrike extends MapEffect {
  final (int, int) target;
  final UnitType lead;
  final int count;
  final List<StrikeRound> rounds;
  final bool victory;

  /// Sprite of the lair's monster.
  final String lairSprite;

  const MapStrike({
    required this.target,
    required this.lead,
    required this.count,
    required this.rounds,
    required this.victory,
    required this.lairSprite,
  });

  /// The attack on [lair], at [target], that ended in [result].
  factory MapStrike.of({
    required (int, int) target,
    required MonsterLair lair,
    required FightMonsterResult result,
  }) {
    return MapStrike(
      target: target,
      lead: strikeLeadOf(result.sent) ?? UnitType.scout,
      count: result.sent.values.fold(0, (sum, count) => sum + count),
      rounds: [
        for (final turn in result.fight?.turnSummaries ?? const [])
          (
            dealt: turn.damageDealtByPlayer,
            taken: turn.damageDealtByMonster,
          ),
      ],
      victory: result.victory,
      lairSprite: lair.svgPath,
    );
  }

  @override
  Set<String> get imagePaths => {lead.iconPath};

  @override
  MapEffectRun stage(MapStage stage) => MapStrikeRun(
        this,
        stage: stage,
        geometry: StrikeGeometry(origin: stage.originOf(target), target: target),
      );
}
