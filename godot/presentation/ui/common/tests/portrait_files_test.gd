extends TestCase
## Where the renders of the models are and what they are called.


func test_names_a_portrait_after_the_enum_value_in_lower_case() -> void:
	assert_eq(PortraitFiles.building(BuildingType.Value.HEADQUARTERS), "headquarters")
	assert_eq(PortraitFiles.building(BuildingType.Value.SOLAR_PANEL), "solar_panel")
	assert_eq(PortraitFiles.unit(UnitType.Value.DOME_BREAKER), "dome_breaker")
	assert_eq(PortraitFiles.monster(MonsterFamily.Value.SWARM), "swarm")
	assert_eq(PortraitFiles.monster(null), "", "a lair of generic monsters has no family")


func test_every_name_is_told_once() -> void:
	var names := PortraitFiles.names()
	assert_eq(names.size(), 11 + 6 + 5)
	var seen: Dictionary[String, bool] = {}
	for each in names:
		assert_false(seen.has(each), each)
		seen[each] = true


func test_gives_the_render_of_a_model_that_has_one_and_null_for_the_others() -> void:
	assert_not_null(PortraitFiles.texture("headquarters"))
	assert_eq(PortraitFiles.texture("headquarters").get_width(), 256)
	assert_null(PortraitFiles.texture("no_such_portrait"))
	assert_null(PortraitFiles.texture(""))
	assert_eq(PortraitFiles.path("scout"), "res://assets/portraits/scout.png")


func test_every_file_of_the_folder_is_the_portrait_of_a_known_name() -> void:
	var known := PortraitFiles.names()
	var found: Array[String] = []
	for file in DirAccess.get_files_at(PortraitFiles.FOLDER):
		if file.ends_with(".png"):
			found.append(file.trim_suffix(".png"))
			assert_has(known, file.trim_suffix(".png"), "no portrait is called " + file)
	assert_has(found, "headquarters")
	assert_has(found, "solar_panel")
	assert_has(found, "coral_citadel")


func test_every_render_is_square_and_as_big_as_the_workshop_draws_it() -> void:
	for file in DirAccess.get_files_at(PortraitFiles.FOLDER):
		if file.ends_with(".png"):
			var texture := PortraitFiles.texture(file.trim_suffix(".png"))
			assert_eq(texture.get_size(), Vector2(256, 256), file)
