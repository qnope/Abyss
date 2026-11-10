extends TestCase
## test/domain/action/attack_held_kernel/attack_held_kernel_test.dart: what
## an attack on a kernel another player holds does. The groups "the
## refusals" and "a kernel just taken" are in
## attack_held_kernel_refusals_test.gd.

const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN
const HORDE := KernelWar.HORDE
const SMALL_GARRISON := KernelWar.SMALL_GARRISON
const FORTRESS := KernelWar.FORTRESS


func _run(war: KernelWar, army: Dictionary[UnitType.Value, int] = HORDE) -> AttackBaseResult:
	var result: AttackBaseResult = ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return result


func _war(kernel_level: int, army: Dictionary[UnitType.Value, int] = HORDE, garrison := {}) -> KernelWar:
	var war := KernelWar.new(kernel_level)
	war.arm(army)
	var units: Dictionary[UnitType.Value, int] = {}
	units.assign(garrison)
	war.garrison(units)
	return war


func _assaults(player: Player) -> Array[HistoryEntry]:
	return player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)


func test_a_won_attack_on_a_held_kernel_lowers_the_kernel_by_one_level_and_leaves_it_to_its_owner() -> void:
	var war := _war(3, HORDE, SMALL_GARRISON)
	var result := _run(war)
	assert_true(result.victory)
	assert_eq(war.kernel_of(war.owner()), 2)
	assert_eq(war.holder(), war.owner().id)


func test_a_won_attack_on_a_held_kernel_gives_the_kernel_to_the_attacker_when_it_falls_to_level_0() -> void:
	var war := _war(1, HORDE, SMALL_GARRISON)
	_run(war)
	assert_eq(war.kernel_of(war.owner()), 0)
	assert_eq(war.holder(), war.attacker().id)


func test_a_won_attack_on_a_held_kernel_loses_the_garrison_of_the_old_owner_with_the_kernel() -> void:
	var war := _war(1, HORDE, SMALL_GARRISON)
	_run(war)
	assert_eq(KernelGarrison.size_of(war.owner()), 0)


func test_a_won_attack_on_a_held_kernel_an_owner_at_level_0_without_garrison_loses_it_at_once() -> void:
	var war := _war(0)
	var result := _run(war)
	assert_true(result.victory)
	assert_eq(war.holder(), war.attacker().id)


func test_a_won_attack_on_a_held_kernel_pillages_nothing_and_leaves_the_rampart_and_headquarters() -> void:
	var war := _war(2, HORDE, SMALL_GARRISON)
	var hq := war.owner().buildings[BuildingType.Value.HEADQUARTERS].level
	var result := _run(war)
	assert_true(result.damage.pillaged.is_empty())
	assert_eq(war.owner().buildings[BuildingType.Value.HEADQUARTERS].level, hq)


func test_the_defence_of_a_held_kernel_is_the_garrison_and_the_magma_rampart() -> void:
	var war := _war(4, HORDE, FORTRESS)
	var result := _run(war)
	assert_eq(result.defence.engaged, FORTRESS)
	assert_false(result.victory)


func test_the_defence_of_a_held_kernel_the_magma_rampart_alone_resists_a_small_army() -> void:
	var war := _war(10, {HARPOONIST: 4})
	var result := _run(war, {HARPOONIST: 4})
	assert_false(result.victory)
	assert_eq(war.kernel_of(war.owner()), 10)
	assert_eq(war.holder(), war.owner().id)


func test_the_defence_of_a_held_kernel_a_lost_attack_sends_the_survivors_of_the_garrison_back() -> void:
	var war := _war(4, {HARPOONIST: 5}, FORTRESS)
	_run(war, {HARPOONIST: 5})
	assert_true(war.count(war.owner(), KernelGarrison.STOCK_KEY, GUARDIAN) > 0)


func test_the_defence_of_a_held_kernel_the_units_on_the_volcano_level_of_the_owner_do_not_defend() -> void:
	var war := _war(0)
	war.put(war.owner(), KernelGarrison.VOLCANO_LEVEL, FORTRESS)
	assert_true(_run(war).victory)


func test_the_defence_of_a_held_kernel_the_army_leaves_the_volcano_level_and_comes_back() -> void:
	var war := _war(4, HORDE, FORTRESS)
	_run(war)
	assert_true(war.count(war.attacker(), KernelGarrison.VOLCANO_LEVEL, HARPOONIST) < 80)


func test_the_history_both_sides_keep_the_assault_with_the_kernel_levels() -> void:
	var war := _war(3, HORDE, SMALL_GARRISON)
	_run(war)
	var mine := _assaults(war.attacker())
	var theirs := _assaults(war.owner())
	assert_eq([mine.size(), theirs.size()], [1, 1])
	var entry: BaseAssaultEntry = mine[0]
	var their_entry: BaseAssaultEntry = theirs[0]
	assert_false(entry.defending)
	assert_true(their_entry.defending)
	assert_eq(entry.post_name, "volcanicKernel")
	assert_eq(entry.rampart_before, 3)
	assert_eq(entry.rampart_after, 2)


func test_a_faction_that_raises_the_kernel_to_level_10_wins_the_game() -> void:
	var war := KernelWar.new(10)
	assert_eq(VictoryChecker.check(war.game), GameStatus.Value.DEFEAT)


## Not in the Dart file: what names the action, and a refused attack that
## leaves no trace.
func test_it_is_the_attack_held_kernel_action_and_a_refusal_leaves_no_trace() -> void:
	var war := KernelWar.new()
	var action := war.strike(HORDE)
	assert_eq(action.type(), ActionType.Value.ATTACK_HELD_KERNEL)
	assert_eq(action.description(), "Assaut Noyau tenu (%d, %d)" % [war.at.x, war.at.y])
	assert_eq(AttackHeldKernelAction.KERNEL_CODE, "volcanicKernel")
	var result := action.execute(war.game, war.attacker())
	assert_eq(result.reason, ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_true(result is AttackBaseResult)
	assert_null(action.make_history_entry(war.game, war.attacker(), ActionResult.success(), 12))
	assert_null(action.make_history_entry(war.game, war.attacker(), result, 12))
	assert_true(war.attacker().raid_state.kernel_attack_turns.is_empty())
	assert_true(_assaults(war.owner()).is_empty())
