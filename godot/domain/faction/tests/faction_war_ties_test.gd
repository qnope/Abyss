extends TestCase
## Not in the Dart files: the branches of the war of the factions that no
## Dart test reaches: ties between targets, a base only the whole army beats,
## fighters already waiting on the volcano level, a level without its kernel
## at the centre, and the Faithful besieging a cold kernel first.

const HARPOONIST := UnitType.Value.HARPOONIST
const Kind := TransitionBaseType.Value


func test_two_bases_as_weak_are_taken_in_the_order_of_their_ids() -> void:
	var war := War.new()
	war.see(war.human())
	war.see(war.rival())
	var turn := war.turn()
	var ours := CombatantBuilder.player_combatants_from(AssaultSamples.HORDE)
	var targets := FactionBaseTargets.weakest_first(turn, ours)
	assert_eq(targets.size(), 2)
	assert_eq(targets[0].strength, targets[1].strength)
	assert_true(targets[0].player.id < targets[1].player.id)


func test_a_base_only_the_whole_army_beats_gets_the_whole_army() -> void:
	var war := War.new()
	war.see(war.human())
	var boost := FightMonsterHelpers.unit_boost_of(war.attacker(), true)
	var planner := FactionTraits.of(war.personality()).planner()
	var m := 1
	while m < 40 and not (
		planner.wins({HARPOONIST: 40}, _defence(war, m), boost)
		and not planner.wins({HARPOONIST: 30}, _defence(war, m), boost)
	):
		m += 1
	assert_true(m < 40, "a defence only the whole horde beats")
	AssaultSamples.station(war.human(), {HARPOONIST: m})

	war.play()

	assert_eq(war.human().raid_state.attacks[0].units, {HARPOONIST: 40})


func test_the_fighters_on_the_volcano_level_join_the_guard_of_the_kernel() -> void:
	var d := KernelDescent.new(8)
	var war := d.war
	var map: GameMap = war.game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": war.attacker().id}))
	war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(
		BuildingType.Value.VOLCANIC_KERNEL, 8
	)
	d.put(1, {HARPOONIST: 100})
	d.put(3, {UnitType.Value.DOME_BREAKER: 40, UnitType.Value.GUARDIAN: 20, UnitType.Value.SCOUT: 3})

	FactionKernelGuard.play(d.turn())

	assert_eq(d.count(1, HARPOONIST), 100, "the fighters below already hold")


func test_a_volcano_level_without_its_kernel_at_the_centre_shows_none() -> void:
	var war := KernelWar.new(3)
	var map: GameMap = war.game.levels[3]
	var cx := DartMath.trunc_div(map.width, 2)
	var cy := DartMath.trunc_div(map.height, 2)
	map.set_cell(cx, cy, map.cell_at(cx, cy).copy_with({"content": CellContentType.Value.EMPTY}))
	assert_null(FactionKernelWar.seen_kernel(_turn(war)))


func test_the_faithful_besiege_a_cold_kernel_before_the_bases() -> void:
	var p: Array[FactionPersonality.Value] = [
		FactionPersonality.Value.KRAKEN_FAITHFUL, FactionPersonality.Value.MURENA_HORDE
	]
	var war := KernelWar.new(3, 7, false, p)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	var faithful := FactionPersonality.Value.KRAKEN_FAITHFUL
	while not FactionWar.is_due(war.game.turn, faithful) or FactionWar.is_grudge_slot(war.game.turn, faithful):
		war.game.turn += 1

	FactionWar.play(_turn(war), faithful)

	assert_eq(war.kernel_of(war.owner()), 2)


func test_posts_as_weak_are_taken_the_shallowest_then_row_by_row() -> void:
	var war := PostWar.new(Kind.FAILLE)
	war.arm(war.attacker())
	war.put(war.attacker(), 2, PostWar.HORDE)
	var deeper := _give(war, 2, Kind.CHEMINEE, BuildingType.Value.PRESSURE_CAPSULE)
	var second := _give(war, 1, Kind.FAILLE, BuildingType.Value.DESCENT_MODULE)
	var first_at := war.at if war.at.y * 1000 + war.at.x < second.y * 1000 + second.x else second

	assert_true(FactionPostWar.play(_turn(war)))

	var taken: TransitionBase = war.game.levels[1].cell_at(first_at.x, first_at.y).transition_base
	assert_eq(taken.captured_by, war.attacker().id)
	assert_eq(war.game.levels[2].cell_at(deeper.x, deeper.y).transition_base.captured_by, war.owner().id)


func test_a_weaker_post_deeper_comes_before_a_stronger_one() -> void:
	var war := PostWar.new(Kind.FAILLE)
	war.arm(war.attacker())
	war.put(war.attacker(), 2, PostWar.HORDE)
	war.put(war.owner(), 2, PostWar.GARRISON)
	var deeper := _give(war, 2, Kind.CHEMINEE, BuildingType.Value.PRESSURE_CAPSULE)

	assert_true(FactionPostWar.play(_turn(war)))

	assert_eq(war.game.levels[2].cell_at(deeper.x, deeper.y).transition_base.captured_by, war.attacker().id)
	assert_eq(war.post.captured_by, war.owner().id)


static func _turn(war: RefCounted) -> FactionTurn:
	var game: Game = war.get("game")
	var attacker: Player = war.call("attacker")
	return FactionTurn.new(game, attacker, ActionExecutor.new(), DartRandom.new(2, false))


## The defence of the human base as a report of `m` Harponneurs shows it.
static func _defence(war: War, m: int) -> Callable:
	var intel := BaseIntel.new(war.game.turn, 1, 0, {HARPOONIST: m}, {})
	return func() -> Array[Combatant]: return BaseDefence.from_intel(intel).side


## Gives the owner of `war` the first other post of `kind` on `level`, with
## its passage, and shows it to the attacker.
static func _give(war: PostWar, level: int, kind: Kind, passage: BuildingType.Value) -> GridPosition:
	var map: GameMap = war.game.levels[level]
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base == null or base == war.post or base.type != kind:
				continue
			base.captured_by = war.owner().id
			war.owner().buildings[passage] = Building.new(passage, 2)
			war.attacker().add_revealed_cell(level, GridPosition.new(x, y))
			return GridPosition.new(x, y)
	return null
