import '../../../../../domain/action/attack_base_result.dart';
import '../../../../../domain/action/attack_transition_base_result.dart';
import '../../../../../domain/action/attack_volcanic_kernel_result.dart';
import '../../../../../domain/action/fight_monster_result.dart';
import '../../../../../domain/fight/fight_result.dart';
import '../../../../../domain/map/monster_lair.dart';
import '../../../../../domain/map/volcanic_kernel_placer.dart';
import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/monster_lair_extensions.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../map_effect.dart';
import 'map_strike_run.dart';
import 'strike_geometry.dart';
import 'strike_lead.dart';
import 'strike_round.dart';

/// An army attacking what stands on [target]: a token showing its [lead]
/// unit and its [count] swims beside it, lunges at it once per turn of
/// the fight (its [rounds]), then on a [victory] a monster fades away
/// while a place lights up, or the token retreats.
class MapStrike extends MapEffect {
  final (int, int) target;
  final UnitType lead;
  final int count;
  final List<StrikeRound> rounds;
  final bool victory;

  /// Sprite of what is attacked: the lair's monster, or the place.
  final String targetSprite;

  /// Whether the target fades away once beaten, as a monster does; a
  /// place stays and lights up instead.
  final bool fades;

  /// Cells the target covers, per side: the volcano covers 2x2.
  final int span;

  const MapStrike({
    required this.target,
    required this.lead,
    required this.count,
    required this.rounds,
    required this.victory,
    required this.targetSprite,
    this.fades = true,
    this.span = 1,
  });

  /// The [fight] of the army [sent] against what is drawn as
  /// [targetSprite] on [target], won on a [victory].
  MapStrike.fought({
    required (int, int) target,
    required String targetSprite,
    required FightResult? fight,
    required Map<UnitType, int> sent,
    required bool victory,
    bool fades = true,
    int span = 1,
  }) : this(
          target: target,
          lead: strikeLeadOf(sent) ?? UnitType.scout,
          count: sent.values.fold(0, (sum, count) => sum + count),
          rounds: roundsOf(fight),
          victory: victory,
          targetSprite: targetSprite,
          fades: fades,
          span: span,
        );

  /// The attack on [lair], at [target], that ended in [result].
  factory MapStrike.of({
    required (int, int) target,
    required MonsterLair lair,
    required FightMonsterResult result,
  }) =>
      MapStrike.fought(
        target: target,
        targetSprite: lair.svgPath,
        fight: result.fight,
        sent: result.sent,
        victory: result.victory,
      );

  /// The assault on the place (a Faille or a Cheminée) drawn as [sprite]
  /// at [target], that ended in [result].
  factory MapStrike.onPlace({
    required (int, int) target,
    required String sprite,
    required AttackTransitionBaseResult result,
  }) =>
      MapStrike.fought(
        target: target,
        targetSprite: sprite,
        fight: result.fight,
        sent: result.sent,
        victory: result.victory,
        fades: false,
      );

  /// The assault on another player's base, or on a place they hold,
  /// drawn as [sprite] over [span] cells from [target], that ended in
  /// [result].
  factory MapStrike.onBase({
    required (int, int) target,
    required String sprite,
    required AttackBaseResult result,
    int span = 1,
  }) =>
      MapStrike.fought(
        target: target,
        targetSprite: sprite,
        fight: result.fight,
        sent: result.sent,
        victory: result.victory,
        fades: false,
        span: span,
      );

  /// The assault on the volcano the kraken guards, drawn as [sprite] from
  /// [target], its top left cell, that ended in [result].
  factory MapStrike.onVolcano({
    required (int, int) target,
    required String sprite,
    required AttackVolcanicKernelResult result,
  }) =>
      MapStrike.fought(
        target: target,
        targetSprite: sprite,
        fight: result.fight,
        sent: result.sent,
        victory: result.victory,
        fades: false,
        span: VolcanicKernelPlacer.side,
      );

  @override
  Set<String> get imagePaths => {lead.iconPath};

  @override
  MapEffectRun stage(MapStage stage) => MapStrikeRun(
        this,
        stage: stage,
        geometry: StrikeGeometry.staged(stage, target, span: span),
      );
}
