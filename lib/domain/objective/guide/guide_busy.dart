import '../../building/building_type.dart';
import '../../game/player.dart';
import 'guide_advice.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// The worksite or the recruitment a target of the guide asks for, already
/// used this turn: the guide then asks to end the turn.
abstract final class GuideBusy {
  static const _endTurn = GuideTarget.endTurn();

  /// The advice to end the turn when [player] cannot touch [target] again
  /// this turn, `null` when they can.
  static GuideAdvice? of(Player player, GuideTarget target) {
    final int hq = player.buildings[BuildingType.headquarters]?.level ?? 0;
    if (target.building != null && player.worksite.freeBuildSites(hq) <= 0) {
      return const GuideAdvice(GuideWorksiteTaken(), _endTurn);
    }
    if (player.recruitedUnitTypes.contains(target.unit)) {
      return const GuideAdvice(GuideAlreadyRecruited(), _endTurn);
    }
    return null;
  }
}
