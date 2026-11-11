extends TestCase
## Not in the Dart files: the steps of ConquestMoves.advance_conquest that
## the Dart tests reach only through whole games (strategies_test.dart,
## waiting for `turn`): the kernel assaulted, a Cheminée held or assaulted.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST
const BREAKER := UnitType.Value.DOME_BREAKER
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
