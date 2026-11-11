extends TestCase
## test/domain/script/faction_tally_sums_test.dart.


func test_merge_sums_counters_and_held_kernel_attacks() -> void:
	var a := FactionTally.new()
	a.bump("f1", "upgrade", 2)
	a.held_kernel_by_level[7] = 1
	var b := FactionTally.new()
	b.bump("f1", "upgrade")
	b.bump("f2", "spy")
	b.held_kernel_by_level[7] = 2
	b.held_kernel_by_level[8] = 1

	a.merge(b)

	assert_eq(a.of("f1", "upgrade"), 3)
	assert_eq(a.of("f2", "spy"), 1)
	assert_eq(a.held_kernel_by_level, {7: 3, 8: 1})


func test_faction_ids_leaves_the_human_out_sorted() -> void:
	var tally := FactionTally.new()
	tally.bump("f2", "spy")
	tally.bump("human", "spy")
	tally.bump("f1", "spy")

	assert_eq(tally.faction_ids(), ["f1", "f2"] as Array[String])


func test_per_turn_divides_by_the_turns_the_player_took_part_in() -> void:
	var tally := FactionTally.new()
	tally.bump("f1", "upgrade", 6)
	tally.played("f1", 2)
	tally.played("f1", 1)

	assert_eq(tally.per_turn("f1", "upgrade"), 2.0)
	assert_eq(tally.per_turn("f2", "upgrade"), 0.0)


func test_faction_mean_is_per_faction_turn_over_the_factions_only() -> void:
	var tally := FactionTally.new()
	tally.bump("f1", "upgrade", 4)
	tally.played("f1", 2)
	tally.bump("f2", "spy")
	tally.played("f2", 6)
	tally.bump("human", "upgrade", 100)
	tally.played("human", 8)

	assert_eq(tally.faction_mean("upgrade"), 0.5)
	assert_eq(FactionTally.new().faction_mean("upgrade"), 0.0)
