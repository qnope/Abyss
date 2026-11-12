extends TestCase
## A siege played on the map: the alert, the attackers closing in, the clashes,
## then the shield or the breach.

const Hard := MonsterDifficulty.Value

var _made: Array[Node] = []


func after_each() -> void:
	for node in _made:
		node.free()


func _effect(held := true, content: Node3D = null) -> SiegeEffect:
	var fight := StrikeSamples.fight([7, 4], [2, 0])
	var siege := MapSiege.by_wave(Vector2i(3, 3), StrikeSamples.lair(MonsterFamily.Value.HUNTER), fight, held)
	var effect := SiegeEffect.new(siege, SiegeGeometry.new(Vector2i(3, 3), 8, 8), content)
	(Engine.get_main_loop() as SceneTree).root.add_child(effect)
	_made.append(effect)
	return effect


func test_it_lasts_as_long_as_the_timeline() -> void:
	var effect := _effect()
	assert_eq(effect.duration(), SiegeTimeline.new(2).total())


func test_the_alert_rings_red_around_the_place_before_the_attackers_come() -> void:
	var effect := _effect()
	effect.advance(SiegeTimeline.ALERT / 4.0)
	var alert := effect.alert
	assert_true(alert.visible)
	assert_almost_eq(alert.scale.x, effect.geometry.radius() * SiegeEffect.ALERT_SCALE, 1e-6)
	assert_eq((alert.material_override as StandardMaterial3D).albedo_color.r, MapPalette.ALERT.r)
	assert_eq(alert.position, effect.geometry.center())


func test_the_attackers_close_in_to_the_place_and_lunge_once_per_round() -> void:
	var effect := _effect()
	var far := effect.attackers.where(0).distance_to(effect.geometry.center())
	effect.advance(SiegeTimeline.ALERT + SiegeTimeline.APPROACH)
	var near := effect.attackers.where(0).distance_to(effect.geometry.center())
	assert_true(near < far)
	effect.advance(effect.timeline.clashes().lunge() / 2.0)
	assert_true(effect.attackers.where(0).distance_to(effect.geometry.center()) < near, "a lunge")
	var player := effect.attackers.figures[0].find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_eq(player.current_animation, "attack")


func test_a_clash_flashes_the_place_shakes_the_map_lightly_and_floats_the_losses() -> void:
	var effect := _effect()
	effect.advance(effect.timeline.clashes().hit_at(0) + 0.03)
	assert_true(effect.flash.visible)
	assert_true(effect.jolt() != 0.0)
	assert_true(absf(effect.jolt()) <= SiegeEffect.CLASH_SHAKE)
	assert_eq(effect.losses.dealt.text, "−2")
	assert_eq(effect.losses.taken.text, "−7")
	assert_true(effect.losses.dealt.visible and effect.losses.taken.visible)


func test_a_loss_of_nothing_floats_nothing() -> void:
	var effect := _effect()
	effect.advance(effect.timeline.clashes().hit_at(1) + 0.03)
	assert_false(effect.losses.dealt.visible, "the second round dealt nothing")
	assert_true(effect.losses.taken.visible)


func test_a_place_that_holds_raises_a_shield_that_pushes_them_back() -> void:
	var effect := _effect(true)
	effect.advance(effect.timeline.impact() - 0.01)
	assert_true(effect.shield_at(effect.elapsed) > 0.9)
	assert_true(effect.shield.visible)
	assert_true(effect.shield_fill.visible)
	var before := effect.attackers.where(0).distance_to(effect.geometry.center())
	effect.advance(SiegeTimeline.OUTCOME / 2.0)
	assert_true(effect.attackers.where(0).distance_to(effect.geometry.center()) > before, "pushed back")
	assert_false(effect.breach.visible)
	effect.finish()
	assert_eq(effect.shield_at(effect.elapsed), 0.0, "the shield is gone at the end")


func test_a_place_that_falls_has_no_shield_and_flashes_red_as_they_break_in() -> void:
	var effect := _effect(false)
	effect.advance(effect.timeline.impact() + SiegeTimeline.OUTCOME / 2.0)
	assert_eq(effect.shield_at(effect.elapsed), 0.0)
	assert_false(effect.shield.visible)
	assert_true(effect.breach.visible)
	var halted := effect.geometry.radius() + SiegeGeometry.HALT * MapGrid.CELL
	assert_true(effect.attackers.where(0).distance_to(effect.geometry.center()) < halted, "breaking in")


func test_the_breach_shakes_the_map_harder_than_a_clash() -> void:
	var effect := _effect(false)
	effect.advance(effect.timeline.impact() + 0.02)
	assert_true(absf(effect.jolt()) > SiegeEffect.CLASH_SHAKE)
	assert_true(absf(effect.jolt()) <= SiegeEffect.BREACH_SHAKE)


func test_the_attackers_play_a_hit_when_pushed_back_and_attack_as_they_break_in() -> void:
	var held := _effect(true)
	held.advance(held.timeline.impact() + 0.01)
	var player := held.attackers.figures[0].find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_eq(player.current_animation, "hit")
	var fallen := _effect(false)
	fallen.advance(fallen.timeline.impact() + 0.01)
	player = fallen.attackers.figures[0].find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
	assert_eq(player.current_animation, "attack")


func test_the_losses_float_over_the_top_of_what_stands_on_the_place() -> void:
	var content := Node3D.new()
	var mesh := MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.position.y = 2.0
	content.add_child(mesh)
	_made.append(content)
	var effect := _effect(true, content)
	effect.advance(effect.timeline.clashes().hit_at(0) + 0.03)
	assert_true(effect.losses.taken.position.y > SiegeEffect.LOSS_HEIGHT)


func test_it_ends_at_once_when_asked_and_rests() -> void:
	var effect := _effect()
	effect.finish()
	assert_true(effect.is_done)
	assert_eq(effect.jolt(), 0.0)
	assert_false(effect.losses.dealt.visible)
