extends TestCase
## test/domain/action/attack_post/attack_post_won_test.dart: what a won
## attack on a post does.

const FAILLE := TransitionBaseType.Value.FAILLE
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN
const HORDE := PostWar.HORDE
const GARRISON := PostWar.GARRISON


func _run(war: PostWar, army: Dictionary[UnitType.Value, int]) -> AttackBaseResult:
	var result: AttackBaseResult = ActionExecutor.new().execute(war.strike(army), war.game, war.attacker())
	return result


func _won(on_below: Dictionary[UnitType.Value, int] = GARRISON) -> PostWar:
	var war := PostWar.new(FAILLE)
	war.arm(war.attacker())
	war.put(war.owner(), 2, on_below)
	return war


func _sum(counts: Dictionary[UnitType.Value, int]) -> int:
	var total := 0
	for n: int in counts.values():
		total += n
	return total


func _assault(player: Player) -> BaseAssaultEntry:
	var assaults := player.history_entries.filter(func(e: HistoryEntry) -> bool: return e is BaseAssaultEntry)
	assert_eq(assaults.size(), 1)
	return assaults[0]


func test_a_won_attack_destroys_the_passage_and_gives_the_post() -> void:
	for kind: TransitionBaseType.Value in TransitionBaseType.Value.values():
		var war := PostWar.new(kind)
		war.arm(war.attacker())
		war.put(war.owner(), war.below(), GARRISON)
		var former := war.owner().id
		var result := _run(war, HORDE)
		assert_true(result.victory, str(kind))
		assert_eq(war.owner().buildings[war.passage()].level, 0)
		assert_eq(war.post.captured_by, war.attacker().id)
		assert_ne(war.post.captured_by, former)


func test_a_won_attack_loses_the_units_the_former_owner_had_on_that_level() -> void:
	var war := _won()
	war.put(war.owner(), 1, {GUARDIAN: 4})
	_run(war, HORDE)
	assert_eq(war.count(war.owner(), 2, HARPOONIST), 0)
	assert_eq(war.count(war.owner(), 1, GUARDIAN), 4)


func test_a_won_attack_leaves_the_post_empty_until_the_attacker_builds_its_passage() -> void:
	var war := _won()
	_run(war, HORDE)
	assert_eq(war.attacker().buildings[war.passage()].level, 0)
	for p: Player in [war.attacker(), war.owner()]:
		var total := 0
		for unit: Unit in KernelGarrison.stock_at(p, 2).values():
			total += unit.count
		assert_eq(total, 0)


func test_a_won_attack_refuses_the_descent_to_the_former_owner_then_to_the_attacker_until_it_has_built_its_own() -> void:
	var war := PostWar.new(FAILLE)
	war.arm(war.attacker())
	war.put(war.owner(), 1, {GUARDIAN: 4})
	war.put(war.owner(), 2, GARRISON)
	_run(war, HORDE)
	var descend := func(t: UnitType.Value) -> DescendAction:
		return DescendAction.new(war.at.x, war.at.y, 1, {t: 1} as Dictionary[UnitType.Value, int])
	war.put(war.owner(), 1, {GUARDIAN: 4})
	war.arm(war.attacker(), {HARPOONIST: 2})
	var owner_descent: DescendAction = descend.call(GUARDIAN)
	assert_eq(owner_descent.validate(war.game, war.owner()).reason, ActionFailure.Value.BASE_NOT_CAPTURED)
	var attacker_descent: DescendAction = descend.call(HARPOONIST)
	assert_eq(attacker_descent.validate(war.game, war.attacker()).reason, ActionFailure.Value.REQUIRED_BUILDING_MISSING)
	war.attacker().buildings[war.passage()] = Building.new(war.passage(), 1)
	var going: DescendAction = descend.call(HARPOONIST)
	var result := ActionExecutor.new().execute(going, war.game, war.attacker())
	assert_true(result.is_success)
	assert_eq(war.count(war.attacker(), 2, HARPOONIST), 1)


func test_a_won_attack_pillages_nothing_and_leaves_the_base_alone() -> void:
	var war := _won()
	var stock := _amounts(war.owner())
	var mine := war.attacker().resources[ResourceType.Value.ALGAE].amount
	var levels := _levels(war)
	var result := _run(war, HORDE)
	assert_true(result.damage.pillaged.is_empty())
	assert_true(result.damage.loot.is_empty())
	assert_eq(_amounts(war.owner()), stock)
	assert_eq(war.attacker().resources[ResourceType.Value.ALGAE].amount, mine)
	assert_eq(_levels(war), levels)


func _amounts(player: Player) -> Dictionary:
	var amounts := {}
	for type: ResourceType.Value in player.resources:
		amounts[type] = player.resources[type].amount
	return amounts


func _levels(war: PostWar) -> Dictionary:
	var levels := {}
	for type: BuildingType.Value in war.owner().buildings:
		if type != war.passage():
			levels[type] = war.owner().buildings[type].level
	return levels


func test_a_won_attack_costs_the_attacker_its_casualties_as_any_fight() -> void:
	var war := _won({GUARDIAN: 25, HARPOONIST: 25})
	var result := _run(war, HORDE)
	var back := war.count(war.attacker(), 1, HARPOONIST)
	assert_eq(back, _sum(result.survivors_intact) + _sum(result.wounded))
	assert_true(back < 60)


func test_a_won_attack_writes_a_history_entry_for_each_side() -> void:
	var war := _won()
	_run(war, HORDE)
	var mine := _assault(war.attacker())
	var theirs := _assault(war.owner())
	assert_false(mine.defending)
	assert_true(theirs.defending)
	assert_true(mine.victory and theirs.victory)
	assert_eq(mine.opponent_name, war.owner().name)
	assert_eq(theirs.opponent_name, war.attacker().name)
	assert_eq(mine.post_name, war.post.name)
	assert_eq(theirs.post_name, war.post.name)
	assert_true(mine.pillaged.is_empty())


func test_a_won_attack_is_felt_as_a_fight_by_the_noise_gauge() -> void:
	var war := PostWar.new(FAILLE)
	war.arm(war.attacker())
	var before := war.attacker().raid_state.noise
	_run(war, HORDE)
	assert_true(war.attacker().raid_state.noise > before)
