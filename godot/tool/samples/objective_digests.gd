class_name ObjectiveDigests
extends RefCounted
## What the digest test of the objectives does between the turns of the
## games of GameFactory, as the scratch Dart script did, and the short texts
## it compares with what that script printed.

const Type := BuildingType.Value
## The building one level up each turn: the one at `(turn + index) % 13`.
const PLAN: Array[Type] = [
	Type.HEADQUARTERS, Type.ALGAE_FARM, Type.CORAL_MINE, Type.ORE_EXTRACTOR, Type.SOLAR_PANEL,
	Type.BARRACKS, Type.LABORATORY, Type.HEADQUARTERS, Type.SOLAR_PANEL, Type.CORAL_CITADEL,
	Type.DESCENT_MODULE, Type.PRESSURE_CAPSULE, Type.VOLCANIC_KERNEL,
]


## Develops the player `p`, at `index` in the game, at the start of turn
## `t`: a building, scouts, an admiral, harpoonists on level 2, the first
## node of the military branch, a ring of cells revealed, a raid announced,
## repelled then two lost, a Faille taken and a faction's assault in the
## history, the first lair, Faille and volcanic kernel of the maps taken.
static func develop(game: Game, p: Player, t: int, i: int) -> void:
	p.buildings[PLAN[(t + i) % PLAN.size()]].level += 1
	if (t + i) % 3 == 0:
		_add_units(p, 1, UnitType.Value.SCOUT, 1)
	if t == 12 + i:
		_add_units(p, 1, UnitType.Value.ABYSS_ADMIRAL, 1)
	if t == 16 + i:
		_add_units(p, 2, UnitType.Value.HARPOONIST, 3)
	if t == 4 + 2 * i:
		var military := p.tech_branches[TechBranch.Value.MILITARY]
		military.unlocked = true
		military.research_level = 1
	if t % 4 == i % 4:
		_reveal(game, p, 2 + DartMath.trunc_div(t, 4))
	_raid(p, t, i)
	if t == 9 + i:
		p.add_history_entry(CaptureEntry.new(t, "faille:0", HistorySamples.fight(true)))
	if t == 11 + i:
		p.add_history_entry(BaseAssaultEntry.new(
			t, false, true, "Nacre", HistorySamples.fight(true), {}, {}, {}, {}, 0, 0, 1, 1, {}, {}
		))
	if t == 10 + i:
		_take(game, p, 1, CellContentType.Value.MONSTER_LAIR)
	if t == 14 + i:
		_capture_faille(game, p)
	if t == 18 + i:
		for level: int in game.levels:
			if _take(game, p, level, CellContentType.Value.VOLCANIC_KERNEL):
				break


## `turn +id credit`: an objective completed and the resources credited.
static func completion(t: int, done: ObjectiveCompletion) -> String:
	var credit := PackedStringArray()
	for type: ResourceType.Value in done.credited:
		credit.append("%s:%d" % [DartEnum.name_of(ResourceType.Value, type), done.credited[type]])
	var id := DartEnum.name_of(ObjectiveId.Value, done.objective.id)
	return ("%d +%s %s" % [t, id, " ".join(credit)]).strip_edges(false, true)


## `turn ~kind/last` for an objective of an event under way, or
## `turn -kind/last outcome` for one ended.
static func temporary(t: int, objective: TemporaryObjective, outcome: Variant = null) -> String:
	var kind := DartEnum.name_of(TemporaryObjectiveKind.Value, objective.kind)
	if outcome == null:
		return "%d ~%s/%d" % [t, kind, objective.last_turn]
	var ended: int = outcome
	return "%d -%s/%d %s" % [t, kind, objective.last_turn, DartEnum.name_of(TemporaryObjectiveOutcome.Value, ended)]


## `turn !ids` for the tips that apply to `p` and are not in `seen`,
## in the order of TipId, added to `seen`; "" for none.
static func fresh_tips(game: Game, p: Player, t: int, seen: Dictionary[TipId.Value, bool]) -> String:
	var fresh := PackedStringArray()
	for tip: Tip in TipCatalog.all():
		if not seen.has(tip.id) and tip.applies_to(game, p):
			seen[tip.id] = true
			fresh.append(DartEnum.name_of(TipId.Value, tip.id))
	return "" if fresh.is_empty() else "%d !%s" % [t, " ".join(fresh)]


static func _add_units(p: Player, level: int, type: UnitType.Value, count: int) -> void:
	if not p.units_per_level.has(level):
		var created: Dictionary[UnitType.Value, Unit] = {}
		p.units_per_level[level] = created
	var units: Dictionary[UnitType.Value, Unit] = p.units_per_level[level]
	if not units.has(type):
		units[type] = Unit.new(type)
	units[type].count += count


## The rows `r` cells above and below the base, `r` cells either side.
static func _reveal(game: Game, p: Player, r: int) -> void:
	var map: GameMap = game.levels[1]
	for y: int in [p.base_y - r, p.base_y + r]:
		for x: int in range(p.base_x - r, p.base_x + r + 1):
			if x >= 0 and y >= 0 and x < map.width and y < map.height:
				p.add_revealed_cell(1, GridPosition.new(x, y))


## Announced at `6 + i` for two turns later, repelled at `8 + i`, lost at
## `13 + i` and `15 + i`.
static func _raid(p: Player, t: int, i: int) -> void:
	var raids := p.raid_state
	if t == 6 + i:
		raids.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), t + 2)
	if t == 8 + i:
		raids.record_outcome(true)
		raids.clear_incoming()
	if t == 13 + i or t == 15 + i:
		raids.record_outcome(false)


## The first cell of `content` on `level` no one holds, now held by `p`.
static func _take(game: Game, p: Player, level: int, content: CellContentType.Value) -> bool:
	var map: GameMap = game.levels[level]
	for i: int in map.cells.size():
		var cell := map.cells[i]
		if cell.content == content and cell.collected_by == null:
			map.set_cell(i % map.width, DartMath.trunc_div(i, map.width), cell.copy_with({"collected_by": p.id}))
			return true
	return false


static func _capture_faille(game: Game, p: Player) -> void:
	var map: GameMap = game.levels[1]
	for cell: MapCell in map.cells:
		var post := cell.transition_base
		if post != null and post.type == TransitionBaseType.Value.FAILLE and post.captured_by == null:
			post.captured_by = p.id
			return
