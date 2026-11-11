extends TestCase
## test/domain/script/strategies/siege_moves_test.dart: the volcano army of
## a faction is sized against a kernel held high, the group "against a
## kernel held at level 7" included.

const HARPOONIST := UnitType.Value.HARPOONIST


## The owner holds the kernel at `level` behind a garrison the guardians'
## sizing would never match; the attacker has `on_kernel` harpoonists, an
## admiral and two scouts on the volcano level (enough for the guardians) and
## `home` harpoonists and an admiral at home.
static func _scene(level: int, home := 600, on_kernel := 300) -> KernelDescent:
	var d := KernelDescent.new(level)
	d.war.garrison({UnitType.Value.GUARDIAN: 200, HARPOONIST: 200})
	d.put(3, {HARPOONIST: on_kernel, UnitType.Value.ABYSS_ADMIRAL: 1, UnitType.Value.SCOUT: 2})
	d.put(1, {HARPOONIST: home, UnitType.Value.ABYSS_ADMIRAL: 1})
	return d


static func _advance(d: KernelDescent, besieges := true) -> void:
	ConquestMoves.advance_conquest(d.turn(), ArmyPlanner.new(), 0.5, ConquestMoves.EXPEDITION_SCOUTS, besieges)


static func _beats_holder(d: KernelDescent) -> bool:
	return ArmyPlanner.new().wins(
		{HARPOONIST: d.count(3, HARPOONIST)},
		func() -> Array[Combatant]: return BaseDefence.kernel(d.war.owner()).side
	)


func test_at_level_7_brings_the_home_army_down_to_the_volcano_in_the_same_turn() -> void:
	var d := _scene(7)
	assert_false(_beats_holder(d))

	_advance(d)

	assert_true(d.count(3, HARPOONIST) > 300)
	assert_eq(d.count(2, HARPOONIST), 0, "nobody waits on level 2")
	assert_true(d.count(1, HARPOONIST) > 0, "only a share")
	assert_true(_beats_holder(d))


func test_at_level_7_takes_down_what_waits_on_level_2_with_the_newcomers() -> void:
	var d := _scene(7)
	d.put(2, {HARPOONIST: 20})

	_advance(d)

	assert_eq(d.count(2, HARPOONIST), 0)
	assert_true(d.count(3, HARPOONIST) > 320)


func test_at_level_7_recruits_toward_the_holder_while_the_army_is_too_small() -> void:
	var d := _scene(7, 50)
	d.war.attacker().buildings[BuildingType.Value.BARRACKS] = Building.new(BuildingType.Value.BARRACKS, 5)
	for r: GameResource in d.war.attacker().resources.values():
		r.amount = 200000

	_advance(d)

	var recruited := 0
	for t: UnitType.Value in [UnitType.Value.GUARDIAN, UnitType.Value.DOME_BREAKER, HARPOONIST]:
		recruited += d.count(1, t)
	assert_true(recruited > 50)
	assert_eq(d.count(3, HARPOONIST), 300)


func test_at_level_7_a_reference_script_still_sizes_against_the_guardians() -> void:
	var d := _scene(7)

	_advance(d, false)

	assert_eq(d.count(3, HARPOONIST), 300)
	assert_eq(d.count(1, HARPOONIST), 600)


func test_at_level_7_a_faction_brain_brings_its_army_down() -> void:
	var d := _scene(7)

	FactionBrain.new(FactionPersonality.Value.PEARL_ORDER).play_turn(d.turn())

	assert_true(d.count(3, HARPOONIST) > 300)


func test_nothing_goes_down_to_a_kernel_held_at_level_6() -> void:
	var d := _scene(6)

	_advance(d)

	assert_eq(d.count(3, HARPOONIST), 300)
	assert_eq(d.count(1, HARPOONIST), 600)


func test_nothing_goes_down_to_a_kernel_held_at_level_7_but_never_seen() -> void:
	var d := _scene(7)
	d.war.attacker().revealed_cells_per_level[3] = [] as Array[GridPosition]

	_advance(d)

	assert_eq(d.count(1, HARPOONIST), 600)
