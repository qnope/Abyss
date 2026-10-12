import '../../building/building_cost_calculator.dart';
import '../../building/building_type.dart';
import '../../fight/assault/assault_target.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../objective.dart';
import '../objective_chapter.dart';
import '../objective_id.dart';
import 'guide_advice.dart';
import 'guide_alerts.dart';
import 'guide_assault.dart';
import 'guide_busy.dart';
import 'guide_map.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// The guide past the tutorial chapter: the rift, the chimney and the
/// kernel step by step, and the alerts of [GuideAlerts] from the rift on.
/// The reef says nothing, the awakening only its alerts.
abstract final class GuideCampaign {
  static const _hq = GuideTarget.building(BuildingType.headquarters);

  /// The advice for [player] on [objective], `null` when the guide is
  /// silent.
  static GuideAdvice? of(Game game, Player player, Objective objective) {
    if (objective.chapter.index < ObjectiveChapter.rift.index) return null;
    final ObjectiveId id = objective.id;
    final GuideAdvice? alert = GuideAlerts.of(game, player, id);
    if (alert != null) return alert;
    final GuideAdvice? step = _step(game, player, id);
    if (step == null) return null;
    if (objective.isDone(game, player)) {
      return const GuideAdvice(GuideGoalMet(), GuideTarget.endTurn());
    }
    final GuideAdvice advice = GuideBusy.of(player, step.target) ?? step;
    final AssaultTarget? target = _assaultOf(id);
    if (target != null && GuideAssault.admiralFell(game, player, target)) {
      return GuideAdvice(GuideAdmiralFell(target), advice.target);
    }
    return advice;
  }

  static GuideAdvice? _step(Game game, Player player, ObjectiveId id) {
    if (_assaultOf(id) case final AssaultTarget target) {
      return GuideAssault.of(game, player, target);
    }
    return switch (id) {
      ObjectiveId.descentModule => _passage(
        player,
        id,
        BuildingType.descentModule,
      ),
      ObjectiveId.pressureCapsule => _passage(
        player,
        id,
        BuildingType.pressureCapsule,
      ),
      ObjectiveId.descendLevel2 => _descent(game, player, id, 1),
      ObjectiveId.descendLevel3 => _descent(game, player, id, 2),
      ObjectiveId.hqLevel8 ||
      ObjectiveId.hqLevel10 => GuideAdvice(GuideLesson(id), _hq),
      ObjectiveId.kernelLevel1 => GuideAdvice(
        GuideLesson(id),
        const GuideTarget.building(BuildingType.volcanicKernel),
      ),
      _ => null,
    };
  }

  static AssaultTarget? _assaultOf(ObjectiveId id) => switch (id) {
    ObjectiveId.takeFaille => AssaultTarget.faille,
    ObjectiveId.takeCheminee => AssaultTarget.cheminee,
    ObjectiveId.takeKernel => AssaultTarget.kernel,
    _ => null,
  };

  /// The headquarters [passage] needs, then its card.
  static GuideAdvice _passage(
    Player player,
    ObjectiveId id,
    BuildingType passage,
  ) {
    final int needed =
        const BuildingCostCalculator().prerequisites(passage, 1)[_hqType] ?? 0;
    if ((player.buildings[_hqType]?.level ?? 0) < needed) {
      return GuideAdvice(GuidePassageNeedsHq(passage, needed), _hq);
    }
    return GuideAdvice(GuideLesson(id), GuideTarget.building(passage));
  }

  /// The post held on [from] to go down by.
  static GuideAdvice _descent(
    Game game,
    Player player,
    ObjectiveId id,
    int from,
  ) => GuideAdvice(
    GuideLesson(id),
    GuideMap.heldPostOn(game, player, from) ?? const GuideTarget.map(),
  );

  static const _hqType = BuildingType.headquarters;
}
