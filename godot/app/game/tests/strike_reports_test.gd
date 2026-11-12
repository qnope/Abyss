extends TestCase
## The strike a report waits for.

var _told: Array[String] = []


func _strike() -> MapStrike:
	return StrikeSamples.strike()


func _then() -> void:
	_told.append("then")


func test_the_report_comes_once_the_strike_is_played() -> void:
	var held: Array[Callable] = []
	StrikeReports.play(func(attack: MapStrike, then: Callable) -> void: held.append(then), _strike(), _then)
	assert_eq(_told, [] as Array[String], "not before it is over")
	held[0].call()
	assert_eq(_told, ["then"] as Array[String])


func test_the_strike_is_the_one_asked() -> void:
	var attack := _strike()
	var got: Array[MapStrike] = []
	StrikeReports.play(func(played: MapStrike, then: Callable) -> void: got.append(played), attack, _then)
	assert_eq(got, [attack] as Array[MapStrike])


func test_without_a_map_to_play_it_on_the_report_comes_at_once() -> void:
	StrikeReports.play(Callable(), _strike(), _then)
	assert_eq(_told, ["then"] as Array[String])
