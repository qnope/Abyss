extends TestCase
## test/domain/faction/faction_traits_test.dart: how each personality plays,
## the group "the other seven" included.

const Personality := FactionPersonality.Value
const U := UnitType.Value
const B := BuildingType.Value


func _of(p: Personality) -> FactionTraits:
	return FactionTraits.of(p)


func test_every_personality_has_traits() -> void:
	for p: Personality in Personality.values():
		assert_true(_of(p).cadence > 0)
		assert_true(_of(p).confidence >= 0.5 and _of(p).confidence <= 1)


func test_the_pillagers_strike_often_boldly_with_harpoonists() -> void:
	var pillagers := _of(Personality.WRECK_PILLAGERS)
	var order := _of(Personality.PEARL_ORDER)
	assert_true(pillagers.cadence < order.cadence)
	assert_true(pillagers.confidence < order.confidence)
	assert_has(pillagers.war_mix, U.HARPOONIST)


func test_the_order_builds_its_economy_first_and_arms_with_guardians() -> void:
	var order := _of(Personality.PEARL_ORDER)
	assert_has(order.war_mix, U.GUARDIAN)
	assert_eq(order.growth.back(), B.BARRACKS)
	assert_true(order.cadence > _of(Personality.ANGLER_CULT).cadence)


func test_the_cult_goes_for_the_posts_first() -> void:
	assert_true(_of(Personality.ANGLER_CULT).posts_first)
	assert_false(_of(Personality.PEARL_ORDER).posts_first)


func test_the_other_seven_every_personality_plays_its_own_way() -> void:
	var seen: Dictionary[String, bool] = {}
	for p: Personality in Personality.values():
		var t := _of(p)
		var key := "/".join([
			t.cadence, t.confidence, t.war_mix, t.war_share, t.conquest_share, t.posts_first,
			t.kernel_first, t.guard_share, t.explorers, t.rush_until, t.growth,
		])
		assert_false(seen.has(key), "%s plays like another" % DartEnum.name_of(Personality, p))
		seen[key] = true


func test_the_other_seven_the_horde_rushes_before_turn_30_with_harpoonists() -> void:
	var horde := _of(Personality.MURENA_HORDE)
	assert_eq(horde.war_mix.keys(), [U.HARPOONIST])
	assert_eq(horde.rush_until, 30)
	assert_true(horde.share_on(10) > horde.share_on(40))


func test_the_other_seven_the_guild_waits_builds_the_rampart_early_and_strikes_surely() -> void:
	var guild := _of(Personality.SIPHONOPHORE_GUILD)
	assert_true(guild.confidence > _of(Personality.WRECK_PILLAGERS).confidence)
	assert_true(
		guild.growth.find(B.CORAL_CITADEL)
		< _of(Personality.MURENA_HORDE).growth.find(B.CORAL_CITADEL)
	)


func test_the_other_seven_the_nomads_explore_more_and_raise_the_citadel_last() -> void:
	var nomads := _of(Personality.CURRENT_NOMADS)
	assert_true(nomads.explorers > 2)
	assert_eq(nomads.growth.back(), B.CORAL_CITADEL)


func test_the_other_seven_the_hive_grows_its_farms_and_barracks_first() -> void:
	var hive := _of(Personality.PYROSOME_HIVE)
	assert_eq(hive.growth.slice(0, 2), [B.ALGAE_FARM, B.BARRACKS])


func test_the_other_seven_the_smiths_race_harder_and_take_the_posts_of_the_others() -> void:
	var smiths := _of(Personality.MAGMA_SMITHS)
	assert_true(smiths.conquest_share > 0.5)
	assert_true(smiths.posts_first)


func test_the_other_seven_the_faithful_lay_siege_to_the_kernel_first_and_garrison_it() -> void:
	var faithful := _of(Personality.KRAKEN_FAITHFUL)
	assert_true(faithful.kernel_first)
	assert_true(faithful.guard_share > 0.5)


func test_the_other_seven_the_monks_strike_rarely_with_saboteurs() -> void:
	var monks := _of(Personality.SILENCE_MONKS)
	assert_has(monks.war_mix, U.SABOTEUR)
	for p: Personality in Personality.values():
		assert_true(monks.cadence >= _of(p).cadence)
