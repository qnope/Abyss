extends UiTestCase
## The strip of the noise gauge and of the raid on its way
## (lib/presentation/widgets/raid/raid_status_bar.dart).

var _game: Game
var _state: RaidState


func before_each() -> void:
	_game = GameFactory.new_single_player("Nemo", 1)
	_state = _game.human_player().raid_state


func _bar() -> RaidStatusBar:
	return mount(RaidStatusBar.new(_game)) as RaidStatusBar


func _wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 40, MonsterFamily.Value.SWARM,
		MonsterFamily.Value.ARMOURED, 6)


func test_shows_the_noise_gauge_when_no_raid_is_coming() -> void:
	_state.add_noise(12)
	var bar := _bar()
	assert_true(bar.gauge_row.visible)
	assert_false(bar.alert_row.visible)
	assert_eq(bar.noise_name.text, "Bruit")
	assert_eq(bar.noise_label.text, "12/40")
	assert_eq(bar.gauge.value, 12.0)
	assert_eq(bar.gauge.max_value, 40.0)
	assert_eq(bar.gauge.theme_type_variation, AbyssInputTheme.NOISE_GAUGE)
	assert_no_raw_keys()


func test_a_full_gauge_stays_full() -> void:
	_state.add_noise(55)
	var bar := _bar()
	assert_eq(bar.noise_label.text, "55/40")
	assert_eq(bar.gauge.ratio, 1.0)


func test_shows_the_alert_in_place_of_the_gauge_once_a_raid_is_announced() -> void:
	_state.announce(_wave(), 5)
	_game.turn = 3
	var bar := _bar()
	assert_false(bar.gauge_row.visible)
	assert_true(bar.alert_row.visible)
	assert_eq(bar.alert_label.text, "Raid à la fin du tour 5 : %s" % MonsterLairTexts.wave_label(_wave()))
	assert_eq(bar.alert_label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	_assert_weakness(bar)


func _assert_weakness(bar: RaidStatusBar) -> void:
	assert_true(bar.weakness_label.visible)
	assert_eq(bar.weakness_label.text, str(MonsterLairTexts.weakness_label(_wave())))
	assert_eq(bar.weakness_label.get_theme_color(&"font_color"), AbyssColors.SUCCESS)


func test_says_the_raid_comes_this_turn_when_it_is_due() -> void:
	_state.announce(_wave(), 5)
	_game.turn = 5
	var bar := _bar()
	assert_eq(bar.alert_label.text, "Raid à la fin de ce tour : %s" % MonsterLairTexts.wave_label(_wave()))
	_game.turn = 6
	bar.refresh()
	assert_eq(bar.alert_label.text, "Raid à la fin de ce tour : %s" % MonsterLairTexts.wave_label(_wave()))


func test_a_wave_with_no_weakness_shows_no_weakness_line() -> void:
	_state.announce(MonsterLair.new(MonsterDifficulty.Value.EASY, 5), 5)
	var bar := _bar()
	assert_false(bar.weakness_label.visible)


func test_tells_the_raids_lost_in_a_row_under_the_gauge_or_the_alert() -> void:
	var bar := _bar()
	assert_false(bar.streak_row.visible)
	_state.lost_in_a_row = 2
	bar.refresh()
	assert_true(bar.streak_row.visible)
	assert_eq(bar.streak_label.text, "Raids perdus d'affilée : 2/3")
	_state.announce(_wave(), 5)
	bar.refresh()
	assert_true(bar.streak_row.visible)
	assert_true(bar.alert_row.visible)


func test_goes_back_to_the_gauge_once_the_raid_is_fought() -> void:
	_state.announce(_wave(), 5)
	var bar := _bar()
	_state.clear_incoming()
	bar.refresh()
	assert_true(bar.gauge_row.visible)
	assert_false(bar.alert_row.visible)


func test_follows_the_language() -> void:
	_state.announce(_wave(), 5)
	_state.lost_in_a_row = 1
	var bar := _bar()
	use_language("en")
	assert_eq(bar.alert_label.text, text(&"raidIncomingOnTurn", {"turn": 5, "wave": MonsterLairTexts.wave_label(_wave())}))
	assert_eq(bar.streak_label.text, text(&"raidLostInARow", {"lost": 1, "limit": 3}))
	assert_eq(bar.noise_name.text, text(&"raidNoise"))
	assert_no_raw_keys()
