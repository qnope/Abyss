import 'post_tip_triggers.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';

/// The tips of the posts: the admiral who takes them, then holding them,
/// the kernel's garrison, and a post lost.
const List<Tip> postTips = [
  Tip(
    id: TipId.admiral,
    category: TipCategory.map,
    trigger: PostTipTriggers.admiral,
  ),
  Tip(
    id: TipId.postDefence,
    category: TipCategory.threats,
    trigger: PostTipTriggers.postHeld,
  ),
  Tip(
    id: TipId.kernelGarrison,
    category: TipCategory.threats,
    trigger: PostTipTriggers.kernelGarrison,
  ),
  Tip(
    id: TipId.postLost,
    category: TipCategory.threats,
    trigger: PostTipTriggers.postLost,
  ),
];
