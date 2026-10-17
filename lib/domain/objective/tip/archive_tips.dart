import 'archive_tip_triggers.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The Archives of the Trench: the lore of the abyss, told card by card
/// as the player reaches it, from the first raid to the kernel.
const List<Tip> archiveTips = [
  Tip(
    id: TipId.abyssListens,
    category: TipCategory.archives,
    trigger: TipTriggers.raidFought,
  ),
  Tip(
    id: TipId.rivalColonies,
    category: TipCategory.archives,
    trigger: ArchiveTipTriggers.rivalColony,
  ),
  Tip(
    id: TipId.ancients,
    category: TipCategory.archives,
    trigger: ArchiveTipTriggers.faille,
  ),
  Tip(
    id: TipId.forgeTowers,
    category: TipCategory.archives,
    trigger: ArchiveTipTriggers.belowReef,
  ),
  Tip(
    id: TipId.awakening,
    category: TipCategory.archives,
    trigger: ArchiveTipTriggers.kernel,
  ),
];
