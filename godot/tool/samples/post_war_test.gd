extends TestCase
## Not in the Dart files: the games of PostWar and KernelWar, a post and a
## kernel held by a faction, the other one ready to strike.


func test_a_faction_holds_a_faille_with_its_passage_and_no_unit_around() -> void:
	var war := PostWar.new(TransitionBaseType.Value.FAILLE)
	assert_eq([war.game.turn, war.level, war.below()], [12, 1, 2])
	assert_eq(war.post.captured_by, war.owner().id)
	assert_ne(war.owner().id, war.attacker().id)
	assert_eq(Building.level_in(war.owner().buildings, war.passage()), 2)
	assert_true(war.attacker().revealed_cells_set_on_level(1).has(war.at.key()))
	assert_eq(war.owner().unit_counts_on_level(1), {} as Dictionary[UnitType.Value, int])
	assert_false(ObjectiveMigration.state_of(war.game, war.human()).tutorial_enabled)
	war.arm(war.attacker())
	assert_eq(war.count(war.attacker(), 1, UnitType.Value.HARPOONIST), 60)


func test_the_human_may_hold_a_cheminee() -> void:
	var war := PostWar.new(TransitionBaseType.Value.CHEMINEE, 7, true)
	assert_eq([war.level, war.below()], [2, 3])
	assert_eq(war.passage(), BuildingType.Value.PRESSURE_CAPSULE)
	assert_true(is_same(war.owner(), war.human()))


func test_a_faction_holds_the_kernel_and_the_other_stands_ready() -> void:
	var war := KernelWar.new(2)
	assert_eq(war.holder(), war.owner().id)
	assert_eq(war.kernel_of(war.owner()), 2)
	war.arm()
	war.garrison(KernelWar.SMALL_GARRISON)
	assert_eq(war.count(war.attacker(), KernelGarrison.VOLCANO_LEVEL, UnitType.Value.HARPOONIST), 80)
	assert_eq(KernelGarrison.of(war.owner()), KernelWar.SMALL_GARRISON)
	var human_holds := KernelWar.new(3, 7, true)
	assert_true(is_same(human_holds.owner(), human_holds.human()))
