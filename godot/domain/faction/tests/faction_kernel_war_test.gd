extends TestCase
## test/domain/faction/faction_kernel_war_test.dart: a faction lays siege to
## the kernel another holds, on its war slot.


static func _scene(kernel_level := 3) -> KernelWar:
	var war := KernelWar.new(kernel_level)
	while not FactionWar.is_due(war.game.turn, war.game.factions()[0].personality):
		war.game.turn += 1
	war.attacker().add_revealed_cell(3, war.at)
	return war


static func _play(war: KernelWar) -> void:
	FactionWar.play(
		FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false)),
		war.game.factions()[0].personality,
	)


func test_a_faction_lays_siege_to_a_weakly_held_kernel_it_has_seen() -> void:
	var war := _scene()
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 2)
	assert_eq(War.assaults(war.owner()).size(), 1)


func test_it_takes_the_kernel_when_the_last_level_falls() -> void:
	var war := _scene(1)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)

	_play(war)

	assert_eq(war.holder(), war.attacker().id)


func test_it_leaves_a_kernel_whose_defence_it_would_not_beat() -> void:
	var war := _scene(8)
	war.arm({UnitType.Value.HARPOONIST: 6})
	war.garrison(KernelWar.FORTRESS)

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 8)
	assert_eq(War.assaults(war.attacker()).size(), 0)


func test_it_ignores_a_kernel_its_fog_has_not_shown() -> void:
	var war := _scene()
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	war.attacker().revealed_cells_per_level[3] = [] as Array[GridPosition]

	_play(war)

	assert_eq(war.kernel_of(war.owner()), 3)


func test_a_kernel_of_the_human_falls_at_once_without_announcement() -> void:
	var war := _scene()
	war.arm()
	var map: GameMap = war.game.levels[3]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": war.human().id}))
	war.human().buildings[BuildingType.Value.VOLCANIC_KERNEL] = Building.new(
		BuildingType.Value.VOLCANIC_KERNEL, 1
	)

	_play(war)

	assert_eq(war.holder(), war.attacker().id)
	var entries := War.assaults(war.human())
	assert_eq(entries.size(), 1)
	assert_true(entries[0].defending)
	assert_eq(entries[0].post_name, "volcanicKernel")


## Not in the Dart file: no kernel to see without a volcano level, nor a
## holder when the kernel is free or its holder fell.
func test_it_finds_no_holder_without_a_level_a_holder_or_a_living_one() -> void:
	var war := _scene()
	var turn := FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(2, false))
	assert_eq(FactionKernelWar.holder_of(turn), war.owner())
	war.owner().saved_fallen = true
	assert_null(FactionKernelWar.holder_of(turn))
	var map: GameMap = war.game.levels[3]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": null}))
	assert_null(FactionKernelWar.holder_of(turn))
	war.game.levels.erase(3)
	assert_null(FactionKernelWar.seen_kernel(turn))
