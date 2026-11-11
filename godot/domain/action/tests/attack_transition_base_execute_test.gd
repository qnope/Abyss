extends TestCase
## test/domain/action/attack_transition_base_execute_test.dart: an assault
## on the guardians of the Faille of SiegeSamples.attack_game, on (1, 1) of
## level 1.

const ADMIRAL := UnitType.Value.ABYSS_ADMIRAL
const HARPOONIST := UnitType.Value.HARPOONIST
const SCOUT := UnitType.Value.SCOUT


func _assault(game: Game, units: Dictionary[UnitType.Value, int], seed_: int) -> AttackTransitionBaseResult:
	var action := AttackTransitionBaseAction.new(1, 1, 1, units, DartRandom.new(seed_))
	return action.execute(game, game.human_player())


func _base(game: Game) -> TransitionBase:
	var map: GameMap = game.levels[1]
	return map.cell_at(1, 1).transition_base


func test_execute_victory_with_admiral_alive_captures_the_base() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, UnitType.Value.DOME_BREAKER: 30}
	var game := SiegeSamples.attack_game(army)
	var r := _assault(game, army, 42)
	assert_true(r.is_success)
	assert_true(r.victory)
	assert_true(r.captured)
	assert_true(_base(game).is_captured())
	assert_eq(_base(game).captured_by, "test-uuid")


## 12 harpoonists + seed 94: the player wins but the admiral dies. The
## admiral has 100 hp but 0 atk and 0 def, so it takes damage and cannot
## fight back.
func test_execute_victory_with_admiral_dead_does_not_capture() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, HARPOONIST: 12}
	var game := SiegeSamples.attack_game(army)
	var r := _assault(game, army, 94)
	assert_true(r.victory)
	assert_false(r.captured)
	assert_false(_base(game).is_captured())


func test_execute_defeat_loses_all_sent_units() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, SCOUT: 1}
	var game := SiegeSamples.attack_game(army)
	var r := _assault(game, army, 42)
	assert_true(r.is_success)
	assert_false(r.victory)
	assert_false(r.captured)
	assert_false(_base(game).is_captured())


func test_execute_guardians_reform_after_failed_capture() -> void:
	var game := SiegeSamples.attack_game({ADMIRAL: 2, SCOUT: 2})
	_assault(game, {ADMIRAL: 1, SCOUT: 1}, 42)
	var fresh := GuardianFactory.for_type(TransitionBaseType.Value.FAILLE)
	assert_eq(fresh.size(), 6)
	for g: Combatant in fresh:
		assert_eq(g.current_hp, g.max_hp)


## Not in the Dart file: a refused assault fights nothing and keeps the
## units; one won reports what was sent and the casualties, the units
## left on the level.
func test_execute_refused_then_won_with_its_casualties() -> void:
	var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, HARPOONIST: 30, SCOUT: 0}
	var game := SiegeSamples.attack_game({ADMIRAL: 1, HARPOONIST: 30})
	var refused := AttackTransitionBaseAction.new(2, 2, 1, army, DartRandom.new(3))
	var failure: ActionResult = refused.execute(game, game.human_player())
	assert_eq(failure.reason, ActionFailure.Value.NO_TRANSITION_BASE_HERE)
	assert_eq(game.human_player().unit_counts_on_level(1)[HARPOONIST], 30)
	var r := _assault(game, army, 3)
	assert_eq(r.sent, {ADMIRAL: 1, HARPOONIST: 30})
	var standing := game.human_player().unit_counts_on_level(1)
	for type: UnitType.Value in r.sent:
		var back: int = r.survivors_intact.get(type, 0) + r.wounded.get(type, 0)
		assert_eq(standing.get(type, 0), back, str(type))
		assert_eq(back + r.dead.get(type, 0), r.sent[type], str(type))


## Not in the Dart file: the Assaut des profondeurs, an attacking perk,
## strengthens the assault; the Rempart vivant of the same tier does not.
func test_execute_the_attacking_perk_counts() -> void:
	var fights: Array[String] = []
	for option: TechOption.Value in [TechOption.Value.A, TechOption.Value.B]:
		var army: Dictionary[UnitType.Value, int] = {ADMIRAL: 1, HARPOONIST: 12}
		var game := SiegeSamples.attack_game(army)
		game.human_player().tech_branches[TechBranch.Value.MILITARY] = TechHelpers.researched_branch(
			TechBranch.Value.MILITARY, 4, [TechOption.Value.B, option] as Array[TechOption.Value]
		)
		var r := _assault(game, army, 94)
		fights.append("%d %s %s" % [r.fight.turn_count, r.dead, r.wounded])
	assert_ne(fights[0], fights[1])
