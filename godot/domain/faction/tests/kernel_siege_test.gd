extends TestCase
## test/domain/faction/kernel_siege_test.dart: a kernel held high comes
## before the bases, on the slots and off them.

const Personality := FactionPersonality.Value
## A personality that does not look at kernels first, on a slow cadence.
const ORDER := Personality.PEARL_ORDER


## The owner holds the kernel at `level` with a small garrison; the attacker
## stands ready on the volcano level and, with its base army, has seen the
## base of the owner.
static func _scene(level: int) -> KernelWar:
	var war := KernelWar.new(level, 7, false, [ORDER, Personality.MURENA_HORDE] as Array[Personality])
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	var army: Dictionary[UnitType.Value, int] = {}
	army.merge(AssaultSamples.HORDE)
	army[UnitType.Value.SCOUT] = 2
	war.put(war.attacker(), 1, army)
	war.attacker().add_revealed_cell(1, GridPosition.new(war.owner().base_x, war.owner().base_y))
	return war


func _to_turn(war: KernelWar, wanted: Callable) -> void:
	var limit := war.game.turn + 30
	while not wanted.call(war.game.turn):
		war.game.turn += 1
		if war.game.turn > limit:
			fail("no such turn")
			return


func _on_slot(war: KernelWar) -> void:
	_to_turn(war, func(t: int) -> bool: return FactionWar.is_due(t, ORDER))


func _off_slot(war: KernelWar, siege_turn: bool) -> void:
	_to_turn(war, func(t: int) -> bool:
		return not FactionWar.is_due(t, ORDER) and KernelSiege.is_off_slot(t, ORDER) == siege_turn)


static func _play(war: KernelWar) -> void:
	FactionWar.play(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)), ORDER
	)


static func _hits(war: KernelWar, kernel: bool) -> int:
	var hits := 0
	for e: BaseAssaultEntry in War.assaults(war.owner()):
		if (e.post_name == "volcanicKernel") == kernel:
			hits += 1
	return hits


func test_a_seen_kernel_held_at_level_7_is_besieged_before_the_base() -> void:
	var war := _scene(7)
	_on_slot(war)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 6)
	assert_eq(_hits(war, false), 0)


func test_at_level_6_the_base_still_comes_first_as_before() -> void:
	var war := _scene(6)
	_on_slot(war)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 6)
	assert_eq(_hits(war, false), 1)


func test_an_unseen_kernel_at_level_7_is_left_alone() -> void:
	var war := _scene(7)
	war.attacker().revealed_cells_per_level[3] = [] as Array[GridPosition]
	_on_slot(war)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 7)
	assert_eq(_hits(war, true), 0)


func test_a_pending_attack_on_the_human_does_not_hold_the_siege_back() -> void:
	var war := _scene(7)
	_on_slot(war)
	war.human().raid_state.attacks.append(
		AnnouncedAttack.new(war.attacker().id, {UnitType.Value.HARPOONIST: 1}, war.game.turn + 1, 1)
	)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 6)


func test_off_its_slot_it_besieges_a_hot_kernel_every_other_turn() -> void:
	var war := _scene(7)
	_off_slot(war, false)
	_play(war)
	assert_eq(war.kernel_of(war.owner()), 7)

	_off_slot(war, true)
	_play(war)
	assert_eq(war.kernel_of(war.owner()), 6)
	assert_eq(_hits(war, false), 0)


func test_off_its_slot_a_kernel_below_level_7_is_left_alone() -> void:
	var war := _scene(6)
	_off_slot(war, true)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 6)
