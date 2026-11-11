extends TestCase
## test/domain/faction/faction_traits_war_test.dart: how soon and how surely
## the personalities go to war.

const Personality := FactionPersonality.Value


func test_war_comes_about_a_quarter_sooner_never_under_three_turns() -> void:
	var cadences: Dictionary[Personality, int] = {
		Personality.WRECK_PILLAGERS: 4,
		Personality.PEARL_ORDER: 7,
		Personality.ANGLER_CULT: 4,
		Personality.MURENA_HORDE: 3,
		Personality.SIPHONOPHORE_GUILD: 9,
		Personality.SILENCE_MONKS: 9,
		Personality.CURRENT_NOMADS: 5,
		Personality.PYROSOME_HIVE: 6,
		Personality.MAGMA_SMITHS: 6,
		Personality.KRAKEN_FAITHFUL: 4,
	}
	for p: Personality in Personality.values():
		var name := DartEnum.name_of(Personality, p)
		assert_eq(FactionTraits.of(p).cadence, cadences[p], name)
		assert_true(FactionTraits.of(p).cadence >= 3, name)
	assert_eq(FactionTraits.new().cadence, 5)


func test_the_timid_attack_once_they_win_seven_rehearsals_of_eight() -> void:
	for p: Personality in [
		Personality.PEARL_ORDER, Personality.SILENCE_MONKS, Personality.SIPHONOPHORE_GUILD,
	] as Array[Personality]:
		var planner := FactionTraits.of(p).planner()
		var name := DartEnum.name_of(Personality, p)
		assert_eq(planner.rehearsals, 8, name)
		assert_true(7.0 / 8.0 >= planner.confidence, name)
		assert_true(6.0 / 8.0 < planner.confidence, name)
