class_name ScriptDigests
extends RefCounted
## What the digest test of the scripts (script_digest_test.gd) does between
## the turns of the games of GameFactory and on each turn, as the scratch
## Dart script did, and the short text of a player it compares with what
## that script printed.

const Type := BuildingType.Value
const HARPOONIST := UnitType.Value.HARPOONIST
## The event offered at `4 + 2i` and `11 + i`: the one at `(t + i) % 5`.
const EVENTS: Array[RandomEventType.Value] = [
	RandomEventType.Value.WARM_CURRENT, RandomEventType.Value.COLD_CURRENT,
	RandomEventType.Value.SURVIVORS, RandomEventType.Value.CARAVAN, RandomEventType.Value.PREDATORS,
]


## Develops `p`, at `i` in the game, before turn `t`: worksites freed, stocks
## credited, an army at `2 + i`, a raid at `5 + i` gone at `7 + i`, an event,
## a Faille at `8 + i`, a Cheminée at `9 + i`, a faction's kernel at `10 + i`.
static func develop(game: Game, p: Player, t: int, i: int) -> void:
	p.recruited_unit_types.clear()
	p.worksite.clear()
	var made := TurnProduction.of(p, t, game.difficulty(), [], p.id != game.human_player_id)
	for r: ResourceType.Value in ResourceType.Value.values():
		var res := p.resources[r]
		var gain: int = made.get(r, 0)
		res.amount = mini(res.max_storage, res.amount + gain + 80)
	if t == 2 + i:
		p.buildings[Type.BARRACKS] = Building.new(Type.BARRACKS, 3)
		p.buildings[Type.LABORATORY] = Building.new(Type.LABORATORY, 1)
		p.units_on_level(1)[UnitType.Value.SCOUT].count += 2
		p.units_on_level(1)[HARPOONIST].count += 10
	if t == 5 + i:
		p.raid_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 3 + i, MonsterFamily.Value.SWARM), t + 2)
	if t == 7 + i:
		p.raid_state.clear_incoming()
	if t == 4 + 2 * i or t == 11 + i:
		var events := p.event_state
		events.schedule(100)
		events.set_pending(EVENTS[(t + i) % EVENTS.size()], t)
		events.survivors = 3
		events.trade_from = ResourceType.Value.CORAL
		events.trade_to = ResourceType.Value.ORE
		events.predator_wave = MonsterLair.new(MonsterDifficulty.Value.EASY, 2, MonsterFamily.Value.SWARM)
	if t == 8 + i:
		_hold(game, p, TransitionBaseType.Value.FAILLE)
	if t == 9 + i:
		_hold(game, p, TransitionBaseType.Value.CHEMINEE)
	if t == 10 + i and i > 0 and game.levels.has(3):
		var map := game.levels[3]
		for at: GridPosition in _cells(game, 3, func(c: MapCell) -> bool:
			return c.content == CellContentType.Value.VOLCANIC_KERNEL):
			map.set_cell(at.x, at.y, map.cell_at(at.x, at.y).copy_with({"collected_by": p.id}))
		p.buildings[Type.VOLCANIC_KERNEL] = Building.new(Type.VOLCANIC_KERNEL, 1)
		p.buildings[Type.HEADQUARTERS].level = 10
		KernelGarrison.stock_at(p, 3)[HARPOONIST].count = 4


## The first post of `kind` nobody holds, now `p`'s with its passage, its
## headquarters raised to 8 at least.
static func _hold(game: Game, p: Player, kind: TransitionBaseType.Value) -> void:
	var level := 1 if kind == TransitionBaseType.Value.FAILLE else 2
	var free := _cells(game, level, func(c: MapCell) -> bool:
		return c.transition_base != null and c.transition_base.type == kind and c.transition_base.captured_by == null)
	if free.is_empty():
		return
	var at := free[0]
	game.levels[level].cell_at(at.x, at.y).transition_base.captured_by = p.id
	p.add_revealed_cell(level, at)
	var passage := Type.DESCENT_MODULE if kind == TransitionBaseType.Value.FAILLE else Type.PRESSURE_CAPSULE
	p.buildings[passage] = Building.new(passage, 1)
	var hq := p.buildings[Type.HEADQUARTERS]
	hq.level = maxi(hq.level, 8)


## The moves of a turn, in the order the Dart script plays them; a faction
## is bold with the wreck, sends its scouts ahead and announces attacks.
static func play(turn: ScriptTurn, t: int, faction: bool) -> void:
	var planner := ArmyPlanner.new()
	EventMoves.play_events(turn, planner, true, faction)
	if not faction:
		var step := TutorialMoves.tutorial_step(turn)
		if step != null:
			TutorialMoves.follow_step(turn, step.id)
		if turn.player.raid_state.is_incoming():
			TutorialMoves.follow_raid_advice(turn, planner)
	BattleMoves.defend_base(turn, planner, 0.5)
	BattleMoves.defend_attacks(turn, planner, 0.5)
	ScoutMoves.scout(turn, 2, ConquestMoves.EXPEDITION_SCOUTS, 2, faction)
	BattleMoves.hunt_lairs(turn, planner)
	ExploreMoves.collect_revealed(turn, 1)
	GrowthMoves.research(turn)
	GrowthMoves.grow_in_order(turn, BalancedStrategy.BUILD_ORDER)
	KernelGuardMoves.guard_kernel(turn, planner, 0.5)
	if faction and t >= 10:
		var n := turn.player.units_on_level(1)[HARPOONIST].count
		AssaultMoves.announce_attack(turn, {HARPOONIST: DartMath.trunc_div(n, 2)})
	if t % 5 == 0:
		EconomyStrategy.new().play_turn(turn)
	if t % 3 == 0:
		BalancedStrategy.new().play_turn(turn)


## `stocks|units by level|building levels|research|revealed on 1.2.3|noise|
## explorations|active event|attacks on the human`.
static func state(game: Game, p: Player) -> String:
	var parts := PackedStringArray()
	for r: GameResource in p.resources.values():
		parts.append(str(r.amount))
	var units := ""
	for level: int in p.units_per_level:
		var stock := p.units_on_level(level)
		var held := PackedStringArray()
		for type: UnitType.Value in stock:
			if stock[type].count > 0:
				held.append("%s:%d" % [DartEnum.name_of(UnitType.Value, type), stock[type].count])
		units += "%d[%s]" % [level, ",".join(held)]
	var levels := ""
	for b: Building in p.buildings.values():
		levels += str(b.level)
	var tech := PackedStringArray()
	for s: TechBranchState in p.tech_branches.values():
		tech.append("%d%d" % [1 if s.unlocked else 0, s.research_level])
	var ev := p.event_state
	var active := "null"
	if ev.active != null:
		var type: RandomEventType.Value = ev.active
		active = DartEnum.name_of(RandomEventType.Value, type)
	var attacks := PackedStringArray()
	for a: AnnouncedAttack in game.human_player().raid_state.attacks:
		attacks.append("%s:%d" % [a.attacker_id, a.fight_seed])
	var seen := PackedStringArray()
	for level: int in [1, 2, 3]:
		seen.append(str(p.revealed_cells_on_level(level).size()))
	return "|".join([
		" ".join(parts), units, levels, ".".join(tech), ".".join(seen), str(p.raid_state.noise),
		str(p.pending_explorations.size()), active + ("H" if ev.heating else ""), ",".join(attacks),
	])


static func _cells(game: Game, level: int, test: Callable) -> Array[GridPosition]:
	var found: Array[GridPosition] = []
	var map: GameMap = game.levels.get(level)
	if map == null:
		return found
	for y: int in map.height:
		for x: int in map.width:
			if test.call(map.cell_at(x, y)):
				found.append(GridPosition.new(x, y))
	return found
