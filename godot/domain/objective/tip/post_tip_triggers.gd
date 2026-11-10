class_name PostTipTriggers
extends RefCounted
## lib/domain/objective/tip/post_tip_triggers.dart: the situations of the
## tip cards of the posts: the admiral who leads their assault, a post or
## the kernel held, a post lost. Each check is cheap: a few fields, the
## history, or one pass over the cells.


## An Abyss Admiral stands on any level.
static func admiral(_game: Game, player: Player) -> bool:
	for level: int in player.units_per_level:
		var units: Dictionary[UnitType.Value, Unit] = player.units_per_level[level]
		var unit: Unit = units.get(UnitType.Value.ABYSS_ADMIRAL)
		if unit != null and unit.count > 0:
			return true
	return false


## A Faille or a Cheminée is held by `player`.
static func post_held(game: Game, player: Player) -> bool:
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			if cell.transition_base != null and cell.transition_base.captured_by == player.id:
				return true
	return false


## The kernel is held and built: its garrison can be filled.
static func kernel_garrison(game: Game, player: Player) -> bool:
	return KernelGarrison.kernel_level_of(player) >= 1 and game.is_volcanic_kernel_captured_by(player.id)


## A post of `player` fell to an attacker: the entry of its defence on a
## Faille or a Cheminée, won by the attacker.
static func post_lost(_game: Game, player: Player) -> bool:
	return player.history_entries.any(func(entry: HistoryEntry) -> bool:
		if not entry is BaseAssaultEntry:
			return false
		var assault: BaseAssaultEntry = entry
		return (
			assault.defending
			and assault.victory
			and assault.post_name != null
			and assault.post_name != AttackHeldKernelAction.KERNEL_CODE
		)
	)
