import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the map: what the exploration reveals, and the way down.
const List<Tip> mapTips = [
  Tip(id: TipId.lair, category: TipCategory.map, trigger: TipTriggers.lair),
  Tip(
    id: TipId.chestAndRuins,
    category: TipCategory.map,
    trigger: TipTriggers.chestOrRuins,
  ),
  Tip(
    id: TipId.transitionBase,
    category: TipCategory.map,
    trigger: TipTriggers.transitionBase,
  ),
  Tip(
    id: TipId.descent,
    category: TipCategory.map,
    trigger: TipTriggers.descent,
  ),
];
