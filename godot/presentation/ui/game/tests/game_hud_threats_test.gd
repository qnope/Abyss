extends GameHudCase
## The threats' strips under the resource bar of the game screen
## (game_status_bars.dart): the noise gauge or the raid alert, the guardians
## and the kraken wave, redrawn with the game.

const WAVE_TURN := 5


func _wave() -> MonsterLair:
	return MonsterLair.new(MonsterDifficulty.Value.EASY, 40, MonsterFamily.Value.SWARM)


func test_stacks_the_raid_the_guardians_and_the_kraken_strips_in_that_order() -> void:
	var hud := _show()
	var bars := hud.status_bars.bars()
	assert_true(bars[0] is RaidStatusBar)
	assert_true(bars[1] is LeviathanStatusBar)
	assert_true(bars[2] is VolcanoStatusBar)


func test_shows_the_noise_gauge_of_a_new_game_and_nothing_else() -> void:
	var hud := _show()
	assert_not_null(find_text("Bruit", hud.status_bars))
	assert_false(hud.status_bars.bars()[1].visible)
	assert_false(hud.status_bars.bars()[2].visible)


func test_redraws_the_strips_when_a_raid_is_announced() -> void:
	var hud := _show()
	_game.human_player().raid_state.announce(_wave(), WAVE_TURN)
	hud.refresh()
	assert_null(find_text("Bruit", hud.status_bars))
	assert_not_null(find_text("Raid à la fin du tour %d : %s" % [WAVE_TURN, MonsterLairTexts.wave_label(_wave())], hud.status_bars))


func test_shows_the_kraken_strip_once_a_wave_rises() -> void:
	var hud := _show()
	_game.human_player().volcano_state.announce(VolcanoWaveFactory.from_kernel_level(1), 2)
	hud.refresh()
	assert_true(hud.status_bars.bars()[2].visible)
	assert_no_raw_keys(hud.status_bars)
