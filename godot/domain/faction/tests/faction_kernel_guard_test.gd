extends TestCase
## test/domain/faction/faction_kernel_guard_test.dart: a faction sends its
## idle home army down to a kernel that would fall.

const HARPOONIST := UnitType.Value.HARPOONIST


## The attacker of a KernelDescent holding the kernel at level 8 with
## `garrison`, `home` Harponneurs on its base and `noise` made so far, no raid
## announced.
static func _holder(
	home: int, noise: int, garrison: Dictionary[UnitType.Value, int] = {HARPOONIST: 28}
) -> KernelDescent:
	var d := KernelDescent.new(8)
	var war := d.war
	var map: GameMap = war.game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": war.attacker().id}))
	war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(
		BuildingType.Value.VOLCANIC_KERNEL, 8
	)
	war.put(war.attacker(), KernelGarrison.STOCK_KEY, garrison)
	d.put(1, {HARPOONIST: home})
	war.attacker().raid_state.total_noise = noise
	war.attacker().raid_state.incoming = null
	war.attacker().raid_state.arrival_turn = null
	return d


func test_a_quiet_base_sends_its_share_of_fighters_down_to_a_weak_kernel() -> void:
	var d := _holder(550, 0)

	FactionKernelGuard.play(d.turn(), 0.7)

	assert_eq(d.count(1, HARPOONIST), 550 - 385)
	assert_eq(d.count(3, HARPOONIST), 385)


func test_a_loud_base_keeps_what_holds_the_raid_its_noise_brings_next() -> void:
	# Seed 2 of the Nomads' race, turn 120: 70 % of the home army went down
	# while no raid was announced, and the 167 left lost the next three
	# raids, so the faction fell with 391 fighters on its kernel.
	var d := _holder(550, 2600)

	FactionKernelGuard.play(d.turn(), 0.7)

	assert_true(d.count(1, HARPOONIST) > 550 - 385)


func test_the_base_keeps_the_same_whatever_families_the_dice_would_draw() -> void:
	var kept: Dictionary[int, bool] = {}
	for seed_: int in 12:
		var d := _holder(550, 1500)
		FactionKernelGuard.play(
			FactionTurn.new(d.war.game, d.war.attacker(), ActionExecutor.new(), DartRandom.new(seed_, false)),
			0.7,
		)
		kept[d.count(1, HARPOONIST)] = true

	assert_eq(kept.size(), 1)


func test_a_strong_garrison_keeps_the_home_army_home() -> void:
	var d := _holder(550, 2600, {UnitType.Value.DOME_BREAKER: 40, UnitType.Value.GUARDIAN: 20})

	FactionKernelGuard.play(d.turn(), 0.7)

	assert_eq(d.count(1, HARPOONIST), 550)


## Not in the Dart file: a kernel nobody holds, one at level 10 and one with
## no level are not guarded; an announced raid is the one the base keeps
## what holds; a base that cannot spare anything, or has no Faille to go
## down by, sends nobody.
func test_it_guards_only_a_kernel_it_holds_below_level_10() -> void:
	var d := _holder(550, 0)
	d.war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 10
	FactionKernelGuard.play(d.turn(), 0.7)
	d.war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 0
	FactionKernelGuard.play(d.turn(), 0.7)
	var map: GameMap = d.war.game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(d.war.at.x, d.war.at.y, map.cell_at(d.war.at.x, d.war.at.y).copy_with({"collected_by": null}))
	FactionKernelGuard.play(d.turn(), 0.7)
	assert_eq(d.count(1, HARPOONIST), 550)


func test_an_announced_raid_it_cannot_hold_keeps_everyone_home() -> void:
	var d := _holder(6, 0)
	d.war.attacker().raid_state.incoming = MonsterLair.new(MonsterDifficulty.Value.EASY, 60)
	AssaultSamples.set_level(d.war.attacker(), BuildingType.Value.CORAL_CITADEL, 1)
	FactionKernelGuard.play(d.turn())
	assert_eq(d.count(1, HARPOONIST), 6)
	d.war.attacker().raid_state.incoming = null
	d.war.attacker().buildings[BuildingType.Value.DESCENT_MODULE].level = 0
	FactionKernelGuard.play(d.turn())
	assert_eq(d.count(1, HARPOONIST), 6)


## Not in the Dart file: a kernel at level 1, the lowest, is guarded too.
func test_it_guards_a_kernel_at_level_1() -> void:
	var d := _holder(550, 0, {HARPOONIST: 1})
	d.war.attacker().buildings[BuildingType.Value.VOLCANIC_KERNEL].level = 1
	FactionKernelGuard.play(d.turn(), 0.7)
	assert_true(d.count(3, HARPOONIST) > 1, str(d.count(3, HARPOONIST)))
