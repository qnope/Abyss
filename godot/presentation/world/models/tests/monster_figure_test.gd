extends TestCase
## The monsters of a lair as they show on the map: the model of their family,
## scaled to a cell, or the generic one.

const Family := MonsterFamily.Value
const Hard := MonsterDifficulty.Value

var _made: Array[MonsterFigure] = []


func after_each() -> void:
	for figure in _made:
		figure.free()


func _figure(family: Variant, difficulty := Hard.MEDIUM) -> MonsterFigure:
	var figure := MonsterFigure.new(family, difficulty)
	(Engine.get_main_loop() as SceneTree).root.add_child(figure)
	_made.append(figure)
	return figure


## The longest side of the figure's meshes, on the floor, in metres.
func _length(figure: MonsterFigure) -> float:
	var size := 0.0
	for model in figure.models:
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			var box := model.transform * mesh.get_aabb()
			size = maxf(size, maxf(box.size.x, box.size.z))
	return size


func test_every_family_has_its_model_and_the_generic_monsters_theirs() -> void:
	assert_eq(MonsterFigure.MODELS.size(), Family.size())
	assert_eq(MonsterFigure.SCALES.keys(), MonsterFigure.MODELS.keys())
	var scenes: Dictionary[String, bool] = {}
	for family: Family in Family.values():
		scenes[MonsterFigure.MODELS[family].resource_path] = true
	scenes[MonsterFigure.GENERIC.resource_path] = true
	assert_eq(scenes.size(), Family.size() + 1, "six models, none twice")
	assert_eq(_figure(null).models[0].scene_file_path, MonsterFigure.GENERIC.resource_path)
	assert_eq(_figure(Family.HUNTER).models[0].scene_file_path, MonsterFigure.MODELS[Family.HUNTER].resource_path)


func test_each_is_scaled_to_about_a_cell_the_big_ones_a_little_over() -> void:
	for family: Family in Family.values():
		var length := _length(_figure(family))
		assert_true(length > 0.3 and length < 2.0, "%s is %.2f m" % [family, length])
	assert_true(_length(_figure(null)) < 1.2)


func test_the_harder_the_lair_the_bigger_its_monsters() -> void:
	var easy := _length(_figure(Family.HUNTER, Hard.EASY))
	var hard := _length(_figure(Family.HUNTER, Hard.HARD))
	assert_true(hard > easy)


func test_a_swarm_is_a_small_school_the_harder_the_more_the_others_one_figure() -> void:
	assert_eq(_figure(Family.SWARM, Hard.EASY).models.size(), 3)
	assert_eq(_figure(Family.SWARM, Hard.MEDIUM).models.size(), 4)
	assert_eq(_figure(Family.SWARM, Hard.HARD).models.size(), 5)
	assert_eq(_figure(Family.ARMOURED, Hard.HARD).models.size(), 1)
	assert_eq(_figure(null, Hard.HARD).models.size(), 1)
	var school := _figure(Family.SWARM, Hard.HARD)
	var places: Dictionary[Vector3, bool] = {}
	for model in school.models:
		places[model.position] = true
	assert_eq(places.size(), 5, "each swims at its own place")


func test_they_play_an_animation_together_and_tell_how_long_it_lasts() -> void:
	var school := _figure(Family.SWARM)
	school.play(&"attack", 2.0)
	for model in school.models:
		var player := model.find_children("*", "AnimationPlayer", true, false)[0] as AnimationPlayer
		assert_eq(player.current_animation, "attack")
		assert_eq(player.get_playing_speed(), 2.0)
	assert_true(school.length_of(&"attack") > 0.0)
	assert_eq(school.length_of(&"dance"), 0.0)
