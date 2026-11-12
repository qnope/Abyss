extends TestCase
## The attackers of a siege.

var _made: Array[SiegeAttackers] = []


func after_each() -> void:
	for attackers in _made:
		attackers.free()


func _attackers(unit := true) -> SiegeAttackers:
	var siege := MapSiege.by_army(Vector2i(3, 3), UnitType.Value.HARPOONIST, Color.GREEN,
		StrikeSamples.fight([1], [1]), true) if unit else MapSiege.by_wave(
		Vector2i(3, 3), StrikeSamples.lair(MonsterFamily.Value.HUNTER), StrikeSamples.fight([1], [1]), true)
	var attackers := SiegeAttackers.new(siege)
	(Engine.get_main_loop() as SceneTree).root.add_child(attackers)
	_made.append(attackers)
	return attackers


func _slot(attackers: SiegeAttackers, index: int) -> Node3D:
	return attackers.figures[index].get_parent() as Node3D


func _player(figure: Node) -> AnimationPlayer:
	return figure.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer


func test_it_stands_the_attackers_of_a_siege() -> void:
	assert_eq(_attackers().figures.size(), SiegeGeometry.ATTACKERS)
	assert_eq(_attackers(false).figures.size(), SiegeGeometry.ATTACKERS)


func test_each_stands_where_it_is_put_facing_the_place() -> void:
	var attackers := _attackers()
	attackers.put(1, Vector3(2.0, 0.0, 0.0), Vector3.ZERO)
	assert_eq(attackers.where(1), Vector3(2.0, 0.0, 0.0))
	assert_almost_eq(_slot(attackers, 1).rotation.y, atan2(-(-2.0), 0.0), 1e-6)
	attackers.put(1, Vector3.ZERO, Vector3.ZERO)
	assert_almost_eq(_slot(attackers, 1).rotation.y, PI / 2.0, 1e-6, "kept when there")


func test_it_plays_an_animation_on_every_figure_for_the_time_asked() -> void:
	var attackers := _attackers()
	attackers.play(&"attack", 0.5)
	for figure in attackers.figures:
		var player := _player(figure)
		assert_eq(player.current_animation, "attack")
		assert_almost_eq(player.get_playing_speed(), player.get_animation("attack").length / 0.5, 1e-4)
	attackers.play(&"idle")
	assert_eq(_player(attackers.figures[0]).get_playing_speed(), 1.0)


func test_monsters_play_it_too() -> void:
	var attackers := _attackers(false)
	attackers.play(&"hit")
	assert_eq(_player(attackers.figures[0]).current_animation, "hit")


func test_they_shrink_away_with_their_rings() -> void:
	var attackers := _attackers()
	attackers.vanish(0.5)
	assert_eq(_slot(attackers, 0).scale, Vector3.ONE * 0.5)
	attackers.vanish(1.0)
	assert_true(_slot(attackers, 0).scale.x > 0.0)
