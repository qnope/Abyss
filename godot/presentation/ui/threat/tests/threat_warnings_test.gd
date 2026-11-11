extends ThreatWarningsCase
## The warnings of the end-of-turn question about the raid and the predators
## (test/presentation/screens/game/game_screen_predators_warning_test.dart,
## game_screen_defeat_test.dart).

const LAST_CHANCE := "Si ce raid est perdu, la partie est terminée."


func test_nothing_when_no_threat_strikes() -> void:
	assert_eq(_of(), [] as Array[Control])


func test_warns_of_a_raid_due_this_turn_against_the_defenders_of_the_base() -> void:
	_human.units_on_level(1)[UnitType.Value.HARPOONIST].count = 3
	_human.raid_state.announce(_wave(), 12)
	var warning := _raid()
	assert_eq(warning.defender_count, 3)
	assert_false(warning.last_chance)
	assert_eq(texts(warning), PackedStringArray(
		["Raid ce tour : %s contre 3 défenseurs" % MonsterLairTexts.wave_label(_wave())]))
	assert_no_raw_keys()


func test_a_single_defender_is_not_plural_and_none_is_told() -> void:
	_human.raid_state.announce(_wave(), 12)
	assert_true(texts(_raid())[0].ends_with("contre aucun défenseur"))
	_human.units_on_level(1)[UnitType.Value.GUARDIAN].count = 1
	assert_true(texts(_raid())[0].ends_with("contre 1 défenseur"))


func test_reminds_that_the_third_lost_raid_ends_the_game() -> void:
	_human.raid_state.announce(_wave(), 12)
	_human.raid_state.lost_in_a_row = 2
	var warning := _raid()
	assert_true(warning.last_chance)
	assert_true(warning.last_chance_label.visible)
	assert_eq(texts(warning)[1], LAST_CHANCE)


func test_no_reminder_after_a_single_lost_raid() -> void:
	_human.raid_state.announce(_wave(), 12)
	_human.raid_state.lost_in_a_row = 1
	assert_false(_raid().last_chance_label.visible)


func test_no_warning_while_the_raid_is_still_on_its_way() -> void:
	_human.raid_state.announce(_wave(), 13)
	assert_null(_raid())


func test_warns_of_the_predators_faced_this_turn_without_the_reminder() -> void:
	_human.units_on_level(1)[UnitType.Value.HARPOONIST].count = 3
	_human.event_state.predator_wave = _wave()
	_human.event_state.predators_turn = 12
	var warning := _predators()
	assert_true(warning.predators)
	assert_eq(texts(warning), PackedStringArray(
		["Banc de prédateurs ce tour : %s contre 3 défenseurs" % MonsterLairTexts.wave_label(_wave())]))


func test_the_predators_not_faced_yet_or_gone_are_not_warned_of() -> void:
	assert_null(_predators())
	_human.event_state.predator_wave = _wave()
	assert_null(_predators())
	_human.event_state.predators_turn = 13
	assert_null(_predators())


func test_a_raid_and_a_wave_due_together_are_both_listed_raid_first() -> void:
	_human.raid_state.announce(_wave(), 12)
	_human.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	var warnings := _of()
	assert_eq(warnings.size(), 2)
	assert_true(warnings[0] is RaidDueWarning)
	assert_true(warnings[1] is VolcanoDueWarning)


func test_the_raid_comes_before_the_predators() -> void:
	_human.raid_state.announce(_wave(), 12)
	_human.event_state.predator_wave = _wave()
	_human.event_state.predators_turn = 12
	var warnings := _of()
	assert_false((warnings[0] as RaidDueWarning).predators)
	assert_true((warnings[1] as RaidDueWarning).predators)


func test_follows_the_language() -> void:
	_human.raid_state.announce(_wave(), 12)
	var warning := _raid()
	use_language("en")
	assert_eq(warning.line.label.text, text(&"raidDueThisTurn", {
		"attacker": text(&"raidName"), "wave": MonsterLairTexts.wave_label(_wave()),
		"defenders": text(&"raidDefenders", {"count": 0})}))
	assert_eq(warning.last_chance_label.text, text(&"raidLastChance"))
