class_name KernelWatch
extends GameScript
## lib/domain/script/kernel_watch.dart: plays `inner`, then notes in `tally`
## the held kernel the factions are about to face this turn
## (`kernel_level_at`), and for each faction that could strike it a
## `kernelChance`: fighters on the volcano level while another player holds
## the kernel at level `threshold` or more; a `kernelSeen` too when its own
## fog shows a cell of the volcano. Every other trait of the game is
## `inner`'s.

var inner: GameScript
var tally: FactionTally
var threshold: int


func _init(inner_: GameScript, tally_: FactionTally, threshold_ := 7) -> void:
	inner = inner_
	tally = tally_
	threshold = threshold_


func name() -> String:
	return inner.name()


func player_name() -> String:
	return inner.player_name()


func map_seed() -> Variant:
	return inner.map_seed()


func difficulty() -> Variant:
	return inner.difficulty()


func factions() -> Array[FactionPersonality.Value]:
	return inner.factions()


func factions_play() -> bool:
	return inner.factions_play()


func last_turn() -> Variant:
	return inner.last_turn()


func end_turn_random(turn: int) -> DartRandom:
	return inner.end_turn_random(turn)


func play_turn(turn: ScriptTurn) -> void:
	inner.play_turn(turn)
	var g := turn.game
	var at := _anchor(g)
	var holder: Variant = _holder(g, at)
	var level := 0 if holder == null else KernelGarrison.kernel_level_of(g.players[holder])
	tally.kernel_level_at[g.turn] = level
	if at == null or level < threshold:
		return
	for f: Faction in g.factions():
		var p: Player = g.players[f.id()]
		if p.id == holder or p.has_fallen() or FactionWar.fighters_on(p, KernelGarrison.VOLCANO_LEVEL).is_empty():
			continue
		tally.bump(f.id(), "kernelChance")
		var seen: Dictionary[Vector2i, bool] = {}
		for c: GridPosition in p.revealed_cells_on_level(KernelGarrison.VOLCANO_LEVEL):
			seen[c.key()] = true
		if VolcanicKernelPlacer.footprint(at.x, at.y).any(func(c: Vector2i) -> bool: return seen.has(c)):
			tally.bump(f.id(), "kernelSeen")


## The volcano anchor, always laid at the centre of its level (see
## `VolcanicKernelPlacer.place`), or null without a volcano level. Dart's
## `_kernel` gives it with its holder.
static func _anchor(g: Game) -> GridPosition:
	var map: GameMap = g.levels.get(KernelGarrison.VOLCANO_LEVEL)
	if map == null:
		return null
	return VolcanoFootprint.anchor_of(map, DartMath.trunc_div(map.width, 2), DartMath.trunc_div(map.height, 2))


## The id of the player holding the kernel at `at` (a String), or null.
static func _holder(g: Game, at: GridPosition) -> Variant:
	if at == null:
		return null
	return g.levels[KernelGarrison.VOLCANO_LEVEL].cell_at(at.x, at.y).collected_by
