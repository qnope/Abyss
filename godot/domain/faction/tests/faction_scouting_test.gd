extends TestCase
## test/domain/faction/faction_scouting_test.dart: how deep a faction scouts.
## Its tests of a war slot wait for FactionWar and FactionBrain
## (domain/README.md, "Left for a later lot").

const Personality := FactionPersonality.Value


func test_an_expedition_keeps_6_scouts_deep_the_nomads_8() -> void:
	for p: Personality in Personality.values():
		assert_eq(
			FactionScouting.deep_scouts_of(p),
			8 if p == Personality.CURRENT_NOMADS else 6,
			DartEnum.name_of(Personality, p)
		)
	assert_eq(FactionScouting.DEEP_EXPLORERS, 3)
