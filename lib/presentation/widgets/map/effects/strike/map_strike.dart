import '../../../../../domain/action/fight_monster_result.dart';
import '../../../../../domain/map/monster_lair.dart';
import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/monster_lair_extensions.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../map_effect.dart';
import 'map_strike_run.dart';
import 'strike_geometry.dart';
import 'strike_lead.dart';

/// An army attacking the lair on [target]: a token showing its [lead]
/// unit and its [count] swims beside the lair, lunges at it once per
/// entry of [hits] (the damage each one deals), then the monster fades
/// away on a [victory], or the token retreats.
class MapStrike extends MapEffect {
  /// Number of lunges of an attack.
  static const lunges = 2;

  final (int, int) target;
  final UnitType lead;
  final int count;
  final List<int> hits;
  final bool victory;

  /// Sprite of the lair's monster.
  final String lairSprite;

  const MapStrike({
    required this.target,
    required this.lead,
    required this.count,
    required this.hits,
    required this.victory,
    required this.lairSprite,
  });

  /// The attack on [lair], at [target], that ended in [result].
  factory MapStrike.of({
    required (int, int) target,
    required MonsterLair lair,
    required FightMonsterResult result,
  }) {
    final damage = result.fight?.turnSummaries
            .fold<int>(0, (sum, turn) => sum + turn.damageDealtByPlayer) ??
        0;
    return MapStrike(
      target: target,
      lead: strikeLeadOf(result.sent) ?? UnitType.scout,
      count: result.sent.values.fold(0, (sum, count) => sum + count),
      hits: split(damage, lunges),
      victory: result.victory,
      lairSprite: lair.svgPath,
    );
  }

  /// [total] shared between [parts] as evenly as can be, the first parts
  /// taking what is left over.
  static List<int> split(int total, int parts) => [
        for (var i = 0; i < parts; i++)
          total ~/ parts + (i < total % parts ? 1 : 0),
      ];

  @override
  Set<String> get imagePaths => {lead.iconPath};

  @override
  MapEffectRun stage(MapStage stage) => MapStrikeRun(
        this,
        stage: stage,
        geometry: StrikeGeometry(origin: stage.originOf(target), target: target),
      );
}
