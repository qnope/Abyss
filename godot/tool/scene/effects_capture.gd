extends SceneTree
## Renders the effects of the map for review, as a phone held upright shows it.
## tool/scene_capture.sh runs it:
##   godot --path godot --resolution 780x1688 --script res://tool/scene/effects_capture.gd -- <out dir>
## writes <out dir>/effects_fog_hold.png, _fog_lift.png and _fog_done.png (the
## cells a scout has just seen, under their clouds, lifting, then bare),
## effects_strike_swim.png, _strike_hit.png and _strike_fall.png (the army swimming
## to a lair, a blow landing, the monster beaten), effects_strike_place.png (a place
## taken, lit in cyan) and effects_siege_alert.png, _siege_clash.png, _siege_shield.png
## and _siege_breach.png (the alert around the base, a clash, the shield pushing the
## attackers back, the breach), each with its draw calls and primitives. The
## effects are driven by hand, a moment at a time.

const SETTLE := 3
const LAIR_AT := Vector2i(4, 1)

var _out := ""
var _world: WorldHost
var _game: Game
var _base: Vector2i


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: effects_capture.gd -- <out dir>")
		quit(2)
		return
	_out = args[0]
	DirAccess.make_dir_recursive_absolute(_out)
	_capture()


func _capture() -> void:
	_world = WorldHost.new()
	root.add_child(_world)
	_game = MapCaptureGame.of_three_levels()
	var human := _game.human_player()
	_base = Vector2i(human.base_x, human.base_y)
	_game.levels[1].set_cell(_base.x + LAIR_AT.x, _base.y + LAIR_AT.y, MapCell.new(
		TerrainType.Value.PLAIN, CellContentType.Value.MONSTER_LAIR,
		MonsterLair.new(MonsterDifficulty.Value.MEDIUM, 1, MonsterFamily.Value.HUNTER)))
	await _frames(2)
	_world.show_view(WorldHost.View.MAP)
	_show()
	_world.map.frame(0.1, 0.1)
	_world.map.camera.home()
	_world.map.camera.rig.look(0.0, -58.0, _world.map.camera.rig.default_distance * 0.4)
	_world.map.camera.pan.place(MapGrid.at(_base.x + 2, _base.y + 1, 26, 26))
	await _fog()
	await _strikes()
	await _sieges()
	quit(0)


func _show() -> void:
	_world.map.show_level(MapStates.of(_game, 1))


## The fog of the cells newly seen at the edge of what is seen, over time.
func _fog() -> void:
	var human := _game.human_player()
	for y in range(_base.y - 11, _base.y - 7):
		for x in range(_base.x - 3, _base.x + 6):
			human.add_revealed_cell(1, GridPosition.new(x, y))
	_world.map.camera.pan.place(MapGrid.at(_base.x + 1, _base.y - 7, 26, 26))
	_show()
	var lift := _play() as FogLift
	await _shot("effects_fog_hold")
	lift.advance(0.9)
	await _shot("effects_fog_lift")
	lift.advance(0.6)
	await _shot("effects_fog_done")
	_world.map.camera.pan.place(MapGrid.at(_base.x + 2, _base.y + 1, 26, 26))


func _strikes() -> void:
	var target := _base + LAIR_AT
	var strike := MapStrike.new(target, StrikeSamples.sent(UnitType.Value.HARPOONIST, 12),
		[Vector2i(7, 2), Vector2i(5, 3), Vector2i(9, 0)] as Array[Vector2i], true, StrikeSamples.lair(MonsterFamily.Value.HUNTER))
	_world.map.strike(strike)
	var effect := _play() as StrikeEffect
	await _step(effect, effect.timeline.swim * 0.6, "effects_strike_swim")
	await _step(effect, effect.timeline.hit_at(1) - effect.elapsed + 0.05, "effects_strike_hit")
	await _step(effect, effect.timeline.pace().end() + StrikeTimeline.OUTCOME * 0.7 - effect.elapsed, "effects_strike_fall")
	effect.finish()
	var ruins := _base + MapCaptureGame.RUINS_AT
	_world.map.strike(MapStrike.new(ruins, StrikeSamples.sent(), [Vector2i(5, 1)] as Array[Vector2i], true))
	effect = _play() as StrikeEffect
	await _step(effect, effect.timeline.pace().end() + effect.timeline.pace().lunge() + StrikeTimeline.OUTCOME * 0.5, "effects_strike_place")
	effect.finish()


func _sieges() -> void:
	var lair := StrikeSamples.lair(MonsterFamily.Value.KRAKEN)
	var fight := StrikeSamples.fight([6, 8], [3, 5])
	_world.map.camera.pan.place(MapGrid.at(_base.x, _base.y, 26, 26))
	_world.map.siege(MapSiege.by_wave(_base, lair, fight, true))
	var siege := _play() as SiegeEffect
	await _step(siege, SiegeTimeline.ALERT * 0.25, "effects_siege_alert")
	await _step(siege, siege.timeline.clashes().hit_at(0) - siege.elapsed + 0.05, "effects_siege_clash")
	await _step(siege, siege.timeline.impact() + SiegeTimeline.OUTCOME * 0.3 - siege.elapsed, "effects_siege_shield")
	siege.finish()
	_world.map.siege(MapSiege.by_wave(_base, lair, fight, false))
	siege = _play() as SiegeEffect
	await _step(siege, siege.timeline.impact() + SiegeTimeline.OUTCOME * 0.5, "effects_siege_breach")
	siege.finish()


## The effect the map has just been given, time stopped: it is driven by hand.
func _play() -> MapEffect:
	_world.map.effects.set_process(false)
	return _world.map.effects.current


## Plays [param seconds] more of [param effect], then a shot.
func _step(effect: MapEffect, seconds: float, shot_name: String) -> void:
	effect.advance(seconds)
	await _shot(shot_name)


func _shot(shot_name: String) -> void:
	await _frames(SETTLE)
	var path := _out.path_join("%s.png" % shot_name)
	root.get_texture().get_image().save_png(path)
	print(path)
	print("  draw calls %d, primitives %d, objects %d" % [
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
	])


func _frames(count: int) -> void:
	for i in count:
		await process_frame
