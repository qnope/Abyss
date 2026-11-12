extends TestCase
## The army that attacks, as a group of figures with its count over them.

const Unit := UnitType.Value

var _made: Array[StrikeSquad] = []


func after_each() -> void:
	for squad in _made:
		squad.free()


func _squad(sent := StrikeSamples.sent()) -> StrikeSquad:
	var squad := StrikeSquad.new(sent)
	(Engine.get_main_loop() as SceneTree).root.add_child(squad)
	_made.append(squad)
	return squad


func _player(figure: Node) -> AnimationPlayer:
	return figure.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer


func test_it_stands_the_figures_of_the_army_and_counts_it() -> void:
	var army := StrikeSamples.sent(Unit.HARPOONIST, 12)
	var squad := _squad(army)
	assert_eq(squad.figures.size(), StrikeLead.figures(army).size())
	assert_true(squad.figures.size() > 1)
	assert_eq(squad.badge.text, "×12")
	for figure in squad.figures:
		assert_eq(figure.get_parent(), squad)


func test_the_count_is_that_of_every_unit_sent() -> void:
	var army := StrikeSamples.sent(Unit.HARPOONIST, 2)
	army[Unit.GUARDIAN] = 5
	assert_eq(_squad(army).badge.text, "×7")


func test_it_faces_what_it_attacks_and_keeps_its_way_when_it_is_on_it() -> void:
	var squad := _squad()
	squad.face(Vector3(0.0, 0.0, -1.0))
	assert_almost_eq(squad.rotation.y, 0.0, 1e-6)
	squad.face(Vector3(1.0, 0.0, 0.0))
	assert_almost_eq(squad.rotation.y, -PI / 2.0, 1e-6)
	squad.face(Vector3.ZERO)
	assert_almost_eq(squad.rotation.y, -PI / 2.0, 1e-6)


func test_it_plays_an_animation_on_every_figure_for_the_time_asked() -> void:
	var squad := _squad()
	squad.play(&"attack", 0.5)
	for figure in squad.figures:
		var player := _player(figure)
		assert_eq(player.current_animation, "attack")
		assert_almost_eq(player.get_playing_speed(), player.get_animation("attack").length / 0.5, 1e-4)
	squad.play(&"idle")
	for figure in squad.figures:
		assert_eq(_player(figure).get_playing_speed(), 1.0)


func test_it_shrinks_away_with_its_count() -> void:
	var squad := _squad()
	squad.vanish(0.5)
	assert_eq(squad.scale, Vector3.ONE * 0.5)
	assert_eq(squad.badge.modulate.a, 0.5)
	squad.vanish(1.0)
	assert_true(squad.scale.x > 0.0, "never a singular scale")
