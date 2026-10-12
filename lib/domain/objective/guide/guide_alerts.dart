import '../../faction/undefended_posts.dart';
import '../../game/game.dart';
import '../../game/player.dart';
import '../../map/monster_lair.dart';
import '../../map/transition_base.dart';
import '../../volcano/kernel_defence_advisor.dart';
import '../../volcano/kernel_garrison.dart';
import '../objective_id.dart';
import 'guide_advice.dart';
import 'guide_map.dart';
import 'guide_message.dart';
import 'guide_target.dart';

/// What the guide says before the current objective, whatever it is: a
/// kraken wave the garrison of the kernel would not hold, then a post
/// held with nobody to defend it.
abstract final class GuideAlerts {
  /// The most urgent alert for [player] on objective [id], `null` when
  /// nothing threatens what they hold.
  static GuideAdvice? of(Game game, Player player, ObjectiveId id) =>
      _wave(game, player) ?? _undefended(game, player, id);

  /// A wave announced against a garrison too small to hold it.
  static GuideAdvice? _wave(Game game, Player player) {
    final MonsterLair? wave = player.volcanoState.incoming;
    if (!player.volcanoState.isIncoming || wave == null) return null;
    final GuideTarget? kernel = GuideMap.heldKernel(game, player);
    if (kernel == null) return null;
    final int? needed = KernelDefenceAdvisor.unitsFor(player, wave);
    if (needed != null && needed <= KernelGarrison.sizeOf(player)) {
      return null;
    }
    return GuideAdvice(
      GuideKernelWave(wave.totalCount, needed: needed),
      kernel,
    );
  }

  /// A post held with nobody below ([UndefendedPosts]: its passage built),
  /// unless the objective already asks to go down there.
  static GuideAdvice? _undefended(Game game, Player player, ObjectiveId id) {
    for (final TransitionBase post in UndefendedPosts.of(game, player)) {
      if (id == _descentTo(post.targetLevel)) continue;
      return GuideAdvice(
        GuidePostUndefended(post.type, post.targetLevel),
        GuideMap.postCell(game, post) ?? const GuideTarget.map(),
      );
    }
    return null;
  }

  static ObjectiveId _descentTo(int level) =>
      level == 2 ? ObjectiveId.descendLevel2 : ObjectiveId.descendLevel3;
}
