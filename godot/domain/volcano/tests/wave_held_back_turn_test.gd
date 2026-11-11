extends TestCase
## test/domain/volcano/wave_held_back_turn_test.dart: a kraken wave due on a
## kernel won by a siege that same turn, through the end of the turn.


static func _war(human_holds: bool) -> KernelWar:
	var war := KernelWar.new(4, 7, human_holds)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	return war


## A kraken wave is due on `war`'s kernel at the end of the turn, a faction
## wins a siege of it during that turn (as the factions play before the
## end-of-turn resolver), then the turn ends.
func _siege_then_end_turn(war: KernelWar, wave: MonsterLair) -> TurnResult:
	war.owner().volcano_state.announce(wave, war.game.turn)
	var result := ActionExecutor.new().execute(war.strike(KernelWar.HORDE), war.game, war.attacker())
	assert_true(result.is_success, str(result.reason))
	return TurnResolver.new().resolve(war.game, DartRandom.new(3))


func test_a_won_siege_on_a_faction_kernel_costs_it_one_level_only() -> void:
	var w := _war(false)
	var turn := w.game.turn

	_siege_then_end_turn(w, VolcanoWaveFactory.from_kernel_level(4))

	assert_eq(w.kernel_of(w.owner()), 3)
	assert_eq(w.owner().volcano_state.arrival_turn, turn + 1)


func test_a_won_siege_on_the_human_kernel_costs_one_level_the_wave_is_told() -> void:
	var w := _war(true)
	var turn := w.game.turn
	var wave := VolcanoWaveFactory.from_kernel_level(4)

	var result := _siege_then_end_turn(w, wave)

	var human := w.human()
	assert_eq(w.kernel_of(human), 3)
	assert_null(result.volcano)
	assert_eq(result.announced_wave, wave)
	assert_eq(human.volcano_state.arrival_turn, turn + 1)
