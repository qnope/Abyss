extends TestCase
## Not in the Dart files: the steps of ConquestMoves.advance_conquest that
## the Dart tests reach only through whole games (strategies_test.dart,
## waiting for `turn`): the kernel assaulted, a Cheminée held or assaulted,
## the admirals and the scouts of the descent to a kernel held by another.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST
const BREAKER := UnitType.Value.DOME_BREAKER
const SCOUT := UnitType.Value.SCOUT
const ARMY: Dictionary[UnitType.Value, int] = {HARPOONIST: 120, ADMIRAL: 1}


static func _advance(game: Game) -> Array[ScriptLogEntry]:
	var log_: Array[ScriptLogEntry] = []
	ConquestMoves.advance_conquest(ScriptTurn.new(game, DartRandom.new(1), log_), ArmyPlanner.new())
	return log_


func test_the_capsule_built_it_assaults_the_kernel_it_has_seen() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 1, BREAKER: 240})
	var player := game.human_player()
	player.buildings[BuildingType.Value.PRESSURE_CAPSULE].level = 1
	player.add_revealed_cell(3, GridPosition.new(1, 1))

	var log_ := _advance(game)

	assert_eq(log_.size(), 1)
	assert_true(game.is_volcanic_kernel_captured_by(player.id))


func test_the_module_built_it_assaults_the_cheminee_it_has_seen() -> void:
	var game := SiegeSamples.attack_game(ARMY, TransitionBaseType.Value.CHEMINEE, null, 1, 0,
		CellContentType.Value.TRANSITION_BASE, true, 2)
	var player := game.human_player()
	player.add_revealed_cell(2, GridPosition.new(1, 1))

	_advance(game)

	assert_eq(game.levels[2].cell_at(1, 1).transition_base.captured_by, player.id)


func test_the_cheminee_held_it_waits_for_the_capsule() -> void:
	var game := SiegeSamples.attack_game(ARMY, TransitionBaseType.Value.CHEMINEE, "test-uuid", 1, 0,
		CellContentType.Value.TRANSITION_BASE, true, 2)
	game.human_player().add_revealed_cell(2, GridPosition.new(1, 1))

	assert_eq(_advance(game).size(), 0)


func test_the_names_of_the_strategies() -> void:
	assert_eq(ConquestStrategy.new().name(), "conquest")
	assert_eq(FactionBrain.new(FactionPersonality.Value.MAGMA_SMITHS).name(), "faction-magmaSmiths")


## The descent of KernelDescent, the kernel held by another: `units` per
## level of the attacker.
static func _descent(units: Dictionary[int, Dictionary]) -> KernelDescent:
	var d := KernelDescent.new(8)
	for level: int in units:
		var on: Dictionary[UnitType.Value, int] = {}
		on.assign(units[level])
		d.put(level, on)
	return d


static func _conquer(d: KernelDescent) -> PackedStringArray:
	var spy := FactionDigests.Spy.new()
	ConquestMoves.advance_conquest(
		FactionTurn.new(d.war.game, d.war.attacker(), spy, DartRandom.new(3, false)), ArmyPlanner.new()
	)
	return spy.seen


func test_the_cheminee_held_without_the_capsule_nothing_moves() -> void:
	var d := _descent({1: {BREAKER: 400, ADMIRAL: 1}})
	d.war.attacker().buildings[BuildingType.Value.PRESSURE_CAPSULE].level = 0

	assert_eq(_conquer(d).size(), 0)


func test_an_admiral_below_keeps_the_home_admiral_at_home() -> void:
	var d := _descent({1: {BREAKER: 400, ADMIRAL: 1}, 2: {ADMIRAL: 1}})

	_conquer(d)

	assert_eq(d.count(1, ADMIRAL), 1)
	assert_eq(d.count(3, ADMIRAL), 1)


func test_one_scout_below_the_ready_army_calls_for_more() -> void:
	var d := _descent({1: {SCOUT: 5}, 3: {BREAKER: 400, ADMIRAL: 1, SCOUT: 1}})

	_conquer(d)

	assert_eq(d.count(3, SCOUT), 4)


func test_the_kernel_assault_takes_one_admiral() -> void:
	var game := SiegeSamples.kernel_game({ADMIRAL: 2, BREAKER: 240})
	game.human_player().add_revealed_cell(3, GridPosition.new(1, 1))
	var recorder := Recorder.new()

	ExpeditionMoves.assault(
		ScriptTurn.new(game, DartRandom.new(1), [], null, recorder), 3, GridPosition.new(1, 1), ArmyPlanner.new()
	)

	assert_eq(recorder.sent[0].selected_units[ADMIRAL], 1)


## An ActionExecutor that keeps the assaults on the kernel it executes.
class Recorder:
	extends ActionExecutor

	var sent: Array[AttackVolcanicKernelAction] = []

	func execute(action: Action, game: Game, player: Player) -> ActionResult:
		if action is AttackVolcanicKernelAction:
			sent.append(action)
		return super(action, game, player)
