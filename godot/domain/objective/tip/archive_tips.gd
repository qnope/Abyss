class_name ArchiveTips
extends RefCounted
## lib/domain/objective/tip/archive_tips.dart: the Archives of the Trench,
## the lore of the abyss told card by card as the player reaches it, from
## the first raid to the kernel.


## `archiveTips`, a const list in Dart: new tips at each call.
static func archive_tips() -> Array[Tip]:
	var archives := TipCategory.Value.ARCHIVES
	return [
		Tip.new(TipId.Value.ABYSS_LISTENS, archives, TipTriggers.raid_fought),
		Tip.new(TipId.Value.RIVAL_COLONIES, archives, ArchiveTipTriggers.rival_colony),
		Tip.new(TipId.Value.ANCIENTS, archives, ArchiveTipTriggers.faille),
		Tip.new(TipId.Value.FORGE_TOWERS, archives, ArchiveTipTriggers.below_reef),
		Tip.new(TipId.Value.AWAKENING, archives, ArchiveTipTriggers.kernel),
	]
