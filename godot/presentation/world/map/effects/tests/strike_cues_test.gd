extends TestCase
## The order a strike plays its animations in.

const LUNGE := MapMotion.EVENT_STEP

var _rounds: Array[Vector2i] = [Vector2i(7, 2), Vector2i(4, 0)]


func _cues(swim: float) -> Array[StrikeCues]:
	return StrikeCues.of(StrikeTimeline.new(swim, _rounds.size()), _rounds)


func _told(cues: Array[StrikeCues]) -> Array[String]:
	var told: Array[String] = []
	for cue in cues:
		told.append("%s %s" % ["army" if cue.who == StrikeCues.Who.ARMY else "monster", cue.animation])
	return told


func test_the_army_swims_to_the_lair_and_rests_there() -> void:
	var cues := _cues(0.9)
	assert_eq(cues[0].at, 0.0)
	assert_eq(_told(cues)[0], "army swim")
	assert_eq(cues[1].at, 0.9)
	assert_eq(_told(cues)[1], "army idle")


func test_an_army_that_starts_beside_the_lair_does_not_swim() -> void:
	var cues := _cues(0.0)
	assert_eq(_told(cues)[0], "army idle")
	assert_eq(cues[0].at, 0.0)


func test_each_round_the_army_attacks_the_monster_is_hit_and_strikes_back_if_it_took_damage() -> void:
	var told := _told(_cues(0.9))
	assert_eq(told.slice(2, 7), [
		"army attack", "monster hit", "monster attack", "army hit", "army attack",
	] as Array[String])
	assert_eq(told.slice(7), ["monster hit"] as Array[String], "the second round took nothing: no blow back")


func test_the_cues_come_in_order_of_time_at_the_pace_of_the_fight() -> void:
	var cues := _cues(0.9)
	for index in range(1, cues.size()):
		assert_true(cues[index].at >= cues[index - 1].at, "cue %d" % index)
	assert_almost_eq(cues[2].at, 0.9, 1e-9, "the first lunge sets off when the army is there")
	assert_almost_eq(cues[3].at, 0.9 + LUNGE / 2.0, 1e-9, "the hit lands at the peak")
	assert_almost_eq(cues[4].at, 0.9 + LUNGE / 2.0 + LUNGE / 4.0, 1e-9)
	assert_almost_eq(cues[6].at, 0.9 + LUNGE, 1e-9, "the next lunge")


func test_a_fight_without_rounds_has_only_the_swim() -> void:
	var cues := StrikeCues.of(StrikeTimeline.new(0.9, 0), [] as Array[Vector2i])
	assert_eq(_told(cues), ["army swim", "army idle"] as Array[String])
