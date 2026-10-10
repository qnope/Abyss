import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the base: the noise, the building sites, the research
/// choices.
const List<Tip> baseTips = [
  Tip(
    id: TipId.noiseGauge,
    category: TipCategory.base,
    trigger: TipTriggers.noise,
  ),
  Tip(
    id: TipId.worksites,
    category: TipCategory.base,
    trigger: TipTriggers.worksites,
  ),
  Tip(
    id: TipId.techChoice,
    category: TipCategory.base,
    trigger: TipTriggers.techChoice,
  ),
];
