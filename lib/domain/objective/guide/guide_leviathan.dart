import '../../game/game.dart';
import '../../game/player.dart';
import '../../leviathan/leviathan_defence_advisor.dart';
import '../../leviathan/leviathan_resolver.dart';
import '../../unit/unit.dart';
import 'guide_advice.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// The guide's most urgent word: the guardians strike the Faille at the
/// end of this turn ([LeviathanResolver.announcedNow]). The halo points
/// at the Faille, whose sheet sends units down.
abstract final class GuideLeviathan {
  /// The alert for [player] in [game], `null` when no counter-attack
  /// strikes this turn.
  static GuideAdvice? of(Game game, Player player) {
    final LeviathanAnnouncement? attack = LeviathanResolver.announcedNow(game);
    if (attack == null || player.id != game.humanPlayerId) return null;
    final int level = attack.defendingLevel;
    final int have = player
        .unitsOnLevel(level)
        .values
        .fold(0, (int sum, Unit u) => sum + u.count);
    final int? needed = LeviathanDefenceAdvisor.unitsFor(game, player, level);
    final int missing = needed == null || needed <= have ? 0 : needed - have;
    return GuideAdvice(
      GuideLeviathanReturn(level, missing: missing),
      GuideTarget.cell(attack.level, attack.at),
    );
  }
}
