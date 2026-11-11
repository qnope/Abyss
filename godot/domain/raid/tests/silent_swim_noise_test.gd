extends TestCase
## test/domain/raid/silent_swim_noise_test.dart: the Nage silencieuse of the
## explorer branch silences exploring and fighting.

const UNITS: Dictionary[UnitType.Value, int] = {UnitType.Value.HARPOONIST: 1}


func _silence(player: Player, option := TechOption.Value.B) -> void:
	player.tech_branches[TechBranch.Value.EXPLORER] = TechHelpers.researched_branch(
		TechBranch.Value.EXPLORER, 2, [option] as Array[TechOption.Value]
	)


func _fights() -> Array[Action]:
	return [
		FightMonsterAction.new(1, 1, 1, UNITS), AttackTransitionBaseAction.new(1, 1, 1, UNITS),
		AttackVolcanicKernelAction.new(1, 1, 1, UNITS),
	]


## Not in the Dart file: the attacks on the other players are fights too.
func _attacks() -> Array[Action]:
	return [
		AttackBaseAction.new("rival", UNITS), AttackPostAction.new(1, 1, 1, UNITS),
		AttackHeldKernelAction.new(1, 1, UNITS),
	]


func test_nage_silencieuse_exploring_and_fighting_make_no_noise() -> void:
	var player := ActionSamples.fight_player()
	_silence(player)
	assert_eq(ExploreAction.new(1, 1).noise_made(player), 0)
	for fight: Action in _fights() + _attacks():
		assert_eq(fight.noise_made(player), 0, DartEnum.name_of(ActionType.Value, fight.type()))


func test_nage_silencieuse_without_it_they_keep_their_noise() -> void:
	var player := ActionSamples.fight_player()
	_silence(player, TechOption.Value.A)
	assert_eq(ExploreAction.new(1, 1).noise_made(player), NoiseRules.PER_EXPLORATION)
	for fight: Action in _fights() + _attacks():
		assert_eq(fight.noise_made(player), NoiseRules.PER_FIGHT)


func test_nage_silencieuse_recruiting_stays_noisy() -> void:
	var player := ActionSamples.fight_player()
	_silence(player)
	assert_eq(RecruitUnitAction.new(UnitType.Value.SCOUT, 3).noise_made(player), 3)


func test_nage_silencieuse_a_real_fight_leaves_the_gauge_untouched() -> void:
	var game := ActionSamples.fight_game(MonsterDifficulty.Value.EASY, 1, UNITS)
	var player := game.human_player()
	_silence(player)
	var result := ActionExecutor.new().execute(FightMonsterAction.new(1, 1, 1, UNITS, DartRandom.new(0)), game, player)
	assert_true(result.is_success)
	assert_eq(player.raid_state.noise, 0)
