import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the threats: the raids on the base, the monster families
/// the waves of the Volcano and the attacks of the factions.
const List<Tip> threatTips = [
  Tip(
    id: TipId.raidAnnounced,
    category: TipCategory.threats,
    trigger: TipTriggers.raidAnnounced,
  ),
  Tip(
    id: TipId.raidReport,
    category: TipCategory.threats,
    trigger: TipTriggers.raidFought,
  ),
  Tip(
    id: TipId.lastChance,
    category: TipCategory.threats,
    trigger: TipTriggers.lastChance,
  ),
  Tip(
    id: TipId.monsterFamilies,
    category: TipCategory.threats,
    trigger: TipTriggers.monsterFamily,
  ),
  Tip(
    id: TipId.volcanoWave,
    category: TipCategory.threats,
    trigger: TipTriggers.volcanoWave,
  ),
  Tip(
    id: TipId.factionAttack,
    category: TipCategory.threats,
    trigger: TipTriggers.factionAttack,
  ),
];
