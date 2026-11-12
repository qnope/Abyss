extends TestCase
## The class that plays a model's animations by name, on the workshop's test
## model (tool/models/catalog/probe_fish): a body and a tail of three bones
## with idle and swim (loops), attack and hit (actions).

const FISH := preload("res://assets/models/probe_fish.glb")
const TAIL := "Rig/Skeleton3D"


func test_finds_the_four_animations_and_stands_in_idle() -> void:
	var animator := _animator()
	assert_true(animator.is_animated())
	assert_eq(animator.animations(), [&"attack", &"hit", &"idle", &"swim"] as Array[StringName])
	assert_eq(animator.current(), ModelAnimator.IDLE)


func test_loops_are_idle_and_swim_and_the_others_are_actions() -> void:
	var animator := _animator()
	assert_false(animator.is_one_shot(&"idle"))
	assert_false(animator.is_one_shot(&"swim"))
	assert_true(animator.is_one_shot(&"attack"))
	assert_true(animator.is_one_shot(&"hit"))
	assert_false(animator.is_one_shot(&"dance"))


func test_a_loop_plays_until_another_is_played() -> void:
	var animator := _animator()
	assert_true(animator.play(&"swim"))
	animator.player.advance(30.0)
	assert_eq(animator.current(), &"swim")
	assert_true(animator.play(&"idle"))
	assert_eq(animator.current(), &"idle")


func test_an_action_gives_back_to_idle_when_it_ends() -> void:
	var animator := _animator()
	assert_true(animator.play(&"attack"))
	assert_eq(animator.current(), &"attack")
	animator.player.advance(0.5)
	assert_eq(animator.current(), &"attack", "still in the middle of it")
	animator.player.advance(2.0)
	assert_eq(animator.current(), ModelAnimator.IDLE)
	assert_true(animator.play(&"hit"))
	animator.player.advance(2.0)
	assert_eq(animator.current(), ModelAnimator.IDLE)


func test_an_animation_the_model_lacks_changes_nothing() -> void:
	var animator := _animator()
	assert_false(animator.play(&"dance"))
	assert_false(animator.has_animation(&"dance"))
	assert_true(animator.has_animation(&"hit"))
	assert_eq(animator.current(), ModelAnimator.IDLE)


func test_the_speed_scales_the_animation() -> void:
	var animator := _animator()
	animator.play(&"attack", 2.0)
	assert_eq(animator.player.get_playing_speed(), 2.0)


func test_the_tail_moves_when_the_fish_swims() -> void:
	var fish := _fish()
	var animator := ModelAnimator.new(fish)
	var skeleton := fish.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	var tail := skeleton.find_bone("Tail3")
	assert_true(tail >= 0)
	var rest := skeleton.get_bone_pose_rotation(tail)
	animator.play(&"swim")
	animator.player.advance(0.15)
	animator.player.advance(0.2)
	assert_false(skeleton.get_bone_pose_rotation(tail).is_equal_approx(rest), "the tail bends")


func test_a_model_without_animation_has_nothing_to_play() -> void:
	var building := (load("res://assets/models/headquarters.glb") as PackedScene).instantiate() as Node3D
	add_cleanup(building.free)
	var animator := ModelAnimator.new(building)
	assert_false(animator.is_animated())
	assert_false(animator.play(&"idle"))
	assert_false(animator.has_animation(&"idle"))
	assert_false(animator.is_one_shot(&"idle"))
	assert_eq(animator.animations(), [] as Array[StringName])
	assert_eq(animator.current(), &"")


func _fish() -> Node3D:
	var fish := FISH.instantiate() as Node3D
	(Engine.get_main_loop() as SceneTree).root.add_child(fish)
	add_cleanup(fish.free)
	return fish


func _animator() -> ModelAnimator:
	return ModelAnimator.new(_fish())
