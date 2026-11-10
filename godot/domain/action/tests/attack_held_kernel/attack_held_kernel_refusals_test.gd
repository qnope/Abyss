extends TestCase
## test/domain/action/attack_held_kernel/attack_held_kernel_test.dart, the
## groups "the refusals" and "a kernel just taken".

const GUARDIAN := UnitType.Value.GUARDIAN
const HORDE := KernelWar.HORDE


func _why(war: KernelWar, army: Dictionary[UnitType.Value, int] = HORDE) -> Variant:
	return war.strike(army).validate(war.game, war.attacker()).reason


func _armed(kernel_level := 3) -> KernelWar:
	var war := KernelWar.new(kernel_level)
	war.arm()
	return war


func _hold(war: KernelWar, id: Variant) -> void:
	var map: GameMap = war.game.levels[3]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": id}))


func test_the_refusals_a_kernel_nobody_holds_is_attacked_through_its_guardians() -> void:
	var war := _armed()
	_hold(war, null)
	assert_eq(_why(war), ActionFailure.Value.KERNEL_NOT_CAPTURED)


func test_the_refusals_one_cannot_attack_its_own_kernel() -> void:
	var war := _armed()
	_hold(war, war.attacker().id)
	assert_eq(_why(war), ActionFailure.Value.CANNOT_ATTACK_SELF)


func test_the_refusals_nobody_attacks_before_the_first_raid() -> void:
	var war := _armed()
	war.game.turn = 3
	assert_eq(_why(war), ActionFailure.Value.ATTACK_TOO_EARLY)


func test_the_refusals_the_army_must_stand_on_the_volcano_level() -> void:
	var war := KernelWar.new()
	assert_eq(_why(war), ActionFailure.Value.NOT_ENOUGH_UNITS)
	assert_eq(_why(war, {}), ActionFailure.Value.NO_UNIT_SELECTED)


func test_the_refusals_the_human_must_have_seen_the_kernel() -> void:
	var war := KernelWar.new()
	war.put(war.human(), 3, HORDE)
	war.human().revealed_cells_per_level[3].clear()
	assert_eq(war.strike(HORDE).validate(war.game, war.human()).reason, ActionFailure.Value.BASE_NOT_REVEALED)


## Not in the Dart file: the refusals the Dart tests leave unchecked, in
## the order the validator checks them.
func test_the_refusals_no_dart_test_reaches() -> void:
	var war := _armed()
	var elsewhere := AttackHeldKernelAction.new(war.at.x + 1, war.at.y, HORDE)
	assert_eq(elsewhere.validate(war.game, war.attacker()).reason, ActionFailure.Value.NO_VOLCANIC_KERNEL_HERE)
	_hold(war, "nobody")
	assert_eq(_why(war), ActionFailure.Value.NO_SUCH_PLAYER)
	var fallen := _armed()
	fallen.owner().saved_fallen = true
	assert_eq(_why(fallen), ActionFailure.Value.PLAYER_FALLEN)
	var protected_ := KernelWar.new(3, 7, true)
	protected_.arm()
	ObjectiveMigration.state_of(protected_.game, protected_.human()).tutorial_enabled = true
	assert_eq(_why(protected_), ActionFailure.Value.ATTACK_TOO_EARLY)
	var hit := _armed()
	var entry := HistorySamples.base_assault_entry(true, false)
	entry.turn = 12
	entry.opponent_name = hit.owner().name
	hit.attacker().add_history_entry(entry)
	assert_eq(_why(hit), ActionFailure.Value.ALREADY_ATTACKED_THIS_TURN)
	var bare := _armed()
	bare.game.levels.erase(3)
	assert_eq(_why(bare), ActionFailure.Value.MAP_NOT_GENERATED)


func test_a_kernel_just_taken_takes_no_garrison_until_it_is_built_to_level_1() -> void:
	var war := _armed(1)
	war.garrison(KernelWar.SMALL_GARRISON)
	ActionExecutor.new().execute(war.strike(HORDE), war.game, war.attacker())
	war.put(war.attacker(), 3, {GUARDIAN: 2})
	var result := GarrisonKernelAction.new({GUARDIAN: 2}).validate(war.game, war.attacker())
	assert_eq(result.reason, ActionFailure.Value.KERNEL_NOT_BUILT)


func test_a_kernel_just_taken_takes_its_garrison_once_the_kernel_stands_at_level_1() -> void:
	var war := _armed(1)
	war.garrison(KernelWar.SMALL_GARRISON)
	ActionExecutor.new().execute(war.strike(HORDE), war.game, war.attacker())
	war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	war.put(war.attacker(), 3, {GUARDIAN: 2})
	var result := GarrisonKernelAction.new({GUARDIAN: 2}).validate(war.game, war.attacker())
	assert_true(result.is_success)
