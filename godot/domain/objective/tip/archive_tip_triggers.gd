class_name ArchiveTipTriggers
extends RefCounted
## lib/domain/objective/tip/archive_tip_triggers.dart: the moments the
## Archives of the Trench open. Each card tells the lore of what the player
## has just reached, and stays true once reached, so a game saved past it
## shows the card once. Each check is cheap: a few fields, the history, or
## one pass over the cells.


## A rival dome found: the base cell of a faction revealed by `player`.
static func rival_colony(game: Game, player: Player) -> bool:
	for faction: Faction in game.factions():
		var rival: Player = game.players.get(faction.id())
		if rival != null and rival.id != player.id and FactionStanding.is_discovered_by(player, rival):
			return true
	return false


## A Faille of the Ancients held by `player`, or captured once.
static func faille(game: Game, player: Player) -> bool:
	if game.captured_base_types_of(player.id).has(TransitionBaseType.Value.FAILLE):
		return true
	for entry: HistoryEntry in player.history_entries:
		if not entry is CaptureEntry:
			continue
		var capture: CaptureEntry = entry
		var name := TransitionBaseName.parse(capture.transition_base_name)
		if capture.captured and name != null and name.type == TransitionBaseType.Value.FAILLE:
			return true
	return false


## Units of `player` standing below the reef: on the level of the Cheminées
## or deeper, the kernel's garrison left out.
static func below_reef(_game: Game, player: Player) -> bool:
	for level: int in range(2, KernelGarrison.VOLCANO_LEVEL + 1):
		if not player.unit_counts_on_level(level).is_empty():
			return true
	return false


## The kernel taken by `player`, or rekindled once: its building is raised
## only once the kernel is taken.
static func kernel(game: Game, player: Player) -> bool:
	return game.is_volcanic_kernel_captured_by(player.id) or KernelGarrison.kernel_level_of(player) >= 1
