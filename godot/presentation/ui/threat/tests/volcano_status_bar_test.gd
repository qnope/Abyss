extends UiTestCase
## The strip of the kraken wave against the kernel's garrison
## (test/presentation/widgets/volcano/volcano_widgets_test.dart).

var _game: Game
var _player: Player


func before_each() -> void:
	_player = RaidSamples.volcano_player(1)
	_game = Game.single_player(_player)
	_game.turn = 12


func _bar() -> VolcanoStatusBar:
	return mount(VolcanoStatusBar.new(_game)) as VolcanoStatusBar


func test_shows_the_wave_against_the_garrison() -> void:
	KernelGarrison.stock_of(_player)[UnitType.Value.GUARDIAN].count = 7
	_player.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	var bar := _bar()
	assert_true(bar.visible)
	assert_true(bar.label.text.contains("3 Krakens"))
	assert_true(bar.label.text.contains("garnison de 7"))
	assert_true(bar.label.text.contains("Noyau niv. 1"))
	assert_eq(bar.label.get_theme_color(&"font_color"), AbyssColors.CORAL_PINK)
	assert_no_raw_keys()


func test_turns_red_when_nobody_guards_the_kernel() -> void:
	_player.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	var bar := _bar()
	assert_true(bar.label.text.contains("garnison de 0"))
	assert_eq(bar.label.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_stays_hidden_without_a_wave() -> void:
	var bar := _bar()
	assert_false(bar.visible)
	assert_eq(texts(bar), PackedStringArray())


func test_appears_and_disappears_with_the_wave() -> void:
	var bar := _bar()
	_player.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 13)
	bar.refresh()
	assert_true(bar.visible)
	_player.volcano_state.clear_incoming()
	bar.refresh()
	assert_false(bar.visible)


func test_follows_the_language() -> void:
	_player.volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 12)
	var bar := _bar()
	use_language("en")
	assert_eq(bar.label.text, text(&"volcanoStatus", {
		"level": 1, "wave": MonsterLairTexts.wave_label(_player.volcano_state.incoming), "size": 0}))
	assert_no_raw_keys()
