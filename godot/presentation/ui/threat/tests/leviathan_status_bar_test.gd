extends UiTestCase
## The red strip of the turn the guardians strike the Faille
## (test/presentation/widgets/leviathan/leviathan_status_bar_test.dart).

const TITLE := "Contre-attaque sur la Faille à la fin du tour"

var _opened: Array[LeviathanAnnouncement] = []


func _scene(turn_offset := 0) -> PostWar:
	var war := LeviathanScene.of()
	LeviathanScene.play_until(war, LeviathanScene.strike_turn(war) + turn_offset)
	return war


func _bar(war: PostWar, tappable := false) -> LeviathanStatusBar:
	var bar := mount(LeviathanStatusBar.new(war.game, tappable)) as LeviathanStatusBar
	bar.opened.connect(_opened.append)
	return bar


func test_nothing_before_the_turn_the_guardians_strike() -> void:
	var bar := _bar(_scene(-1))
	assert_false(bar.visible)
	assert_null(bar.announcement)
	assert_null(find_text(TITLE))


func test_on_that_turn_the_force_and_the_defenders_of_level_2() -> void:
	var war := _scene()
	war.put(war.human(), 2, {UnitType.Value.HARPOONIST: 3, UnitType.Value.GUARDIAN: 2})
	var bar := _bar(war)
	assert_true(bar.visible)
	assert_eq(bar.banner.title_label.text, TITLE)
	assert_eq(bar.banner.detail_label.text, "Léviathan + 4 Sentinelles · défenseurs niv. 2 : 5")
	assert_eq(bar.banner.title_label.get_theme_color(&"font_color"), AbyssColors.ERROR)
	assert_no_raw_keys()


func test_a_touch_opens_the_faille_when_the_strip_is_tappable() -> void:
	var war := _scene()
	var bar := _bar(war, true)
	press(bar.banner.tap)
	assert_eq(_opened.size(), 1)
	assert_eq(_opened[0].at.x, war.at.x)
	assert_eq(_opened[0].at.y, war.at.y)
	assert_eq(_opened[0].level, war.level)


func test_without_an_owner_to_open_it_the_strip_is_not_a_button() -> void:
	assert_null(_bar(_scene()).banner.tap)


func test_follows_the_turn_and_the_language() -> void:
	var war := _scene(-1)
	var bar := _bar(war)
	war.game.turn += 1
	bar.refresh()
	assert_true(bar.visible)
	use_language("en")
	assert_eq(bar.banner.title_label.text, "Counter-attack on the Rift at the end of the turn")
	assert_eq(bar.banner.detail_label.text, "Leviathan + 4 Sentinels · level 2 defenders: 0")
