extends TestCase
## test/domain/script/kernel_watch_test.dart.


func test_notes_the_held_kernel_level_of_the_turn() -> void:
	assert_eq(_watch(KernelWar.new(4)).kernel_level_at, {12: 4})


func test_notes_0_when_nobody_holds_the_kernel() -> void:
	var war := KernelWar.new(8)
	var map: GameMap = war.game.levels[KernelGarrison.VOLCANO_LEVEL]
	map.set_cell(war.at.x, war.at.y, map.cell_at(war.at.x, war.at.y).copy_with({"collected_by": null}))
	war.arm()

	var tally := _watch(war)

	assert_eq(tally.kernel_level_at, {12: 0})
	assert_eq(tally.of(war.attacker().id, "kernelChance"), 0)


func test_a_level_7_kernel_is_a_chance_for_an_armed_faction_seen_or_not() -> void:
	var war := KernelWar.new(7)
	war.arm()

	var tally := _watch(war)

	assert_eq(tally.of(war.attacker().id, "kernelChance"), 1)
	assert_eq(tally.of(war.attacker().id, "kernelSeen"), 1)
	assert_eq(tally.of(war.owner().id, "kernelChance"), 0)


func test_a_kernel_below_level_7_is_no_chance() -> void:
	var war := KernelWar.new(6)
	war.arm()

	assert_eq(_watch(war).of(war.attacker().id, "kernelChance"), 0)


func test_seeing_any_cell_of_the_volcano_counts_as_seeing_the_kernel() -> void:
	var war := KernelWar.new(7)
	war.arm()
	var a := war.attacker()
	var revealed: Array = a.revealed_cells_per_level[KernelGarrison.VOLCANO_LEVEL]
	for i: int in range(revealed.size() - 1, -1, -1):
		var p: GridPosition = revealed[i]
		if p.equals(war.at):
			revealed.remove_at(i)

	assert_eq(_watch(war).of(a.id, "kernelSeen"), 0)
	a.add_revealed_cell(KernelGarrison.VOLCANO_LEVEL, GridPosition.new(war.at.x + 1, war.at.y + 1))
	assert_eq(_watch(war).of(a.id, "kernelSeen"), 1)


func test_keeps_the_traits_of_the_inner_script() -> void:
	var watch := KernelWatch.new(ScriptLibrary.by_name("conquest"), FactionTally.new())

	assert_eq(watch.name(), "conquest")
	assert_eq(watch.player_name(), "conquest")
	assert_true(watch.factions_play())
	assert_null(watch.last_turn())


## Not in the Dart file: every other trait is the inner script's, and a
## game without a volcano level holds no kernel.
func test_keeps_every_other_trait_and_watches_a_game_without_volcano() -> void:
	var inner := AmongFactions.drawn(PlanScript.from_replay(
		DartJson.encode({"mapSeed": 9, "turns": {}, "endTurnSeeds": {"2": 4}}), ReplayVariant.new(),
	), 2, 1)
	var watch := KernelWatch.new(inner, FactionTally.new())
	var game := GameFactory.new_single_player("p", 3)

	watch.play_turn(ScriptTurn.new(game, DartRandom.new(1), []))

	assert_eq(watch.map_seed(), 9)
	assert_null(watch.difficulty())
	assert_eq(watch.factions(), inner.factions())
	assert_eq(watch.end_turn_random(2).initial_seed, 4)
	assert_eq(watch.tally.kernel_level_at, {1: 0})


static func _watch(war: KernelWar) -> FactionTally:
	var tally := FactionTally.new()
	KernelWatch.new(IdleScript.new(), tally).play_turn(ScriptTurn.new(war.game, DartRandom.new(1), []))
	return tally
