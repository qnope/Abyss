extends TestCase
## Every section of every vector file is held by a test of the port or
## waits for a module: none can be forgotten.

const LIB_DOMAIN := "lib/domain"


func test_every_section_of_every_vector_file_is_tested_or_pending() -> void:
	var files := _vector_files()
	assert_true(files.size() >= 17, "found %d vector files" % files.size())
	for file_name: String in files:
		for section: String in VectorFile.new(file_name).section_names():
			var states := VectorRegistry.states_of(file_name, section)
			assert_eq(states.size(), 1, "%s/%s is listed in %s" % [file_name, section, states])


func test_lists_no_file_and_no_section_that_is_gone() -> void:
	var files := _vector_files()
	for file_name: String in VectorRegistry.FILES:
		assert_has(files, file_name)
		if not files.has(file_name):
			continue
		var sections := VectorFile.new(file_name).section_names()
		var states: Dictionary = VectorRegistry.FILES[file_name]
		for state: String in states:
			var listed: Array = states[state]
			for section: String in listed:
				assert_has(sections, section, "%s, listed for %s" % [file_name, state])


func test_a_tested_section_is_read_by_its_test() -> void:
	for file_name: String in VectorRegistry.FILES:
		var states: Dictionary = VectorRegistry.FILES[file_name]
		for state: String in states:
			if not VectorRegistry.pending_module(state).is_empty():
				continue
			assert_true(state.ends_with("_test.gd") and FileAccess.file_exists(state), state)
			var source := FileAccess.get_file_as_string(state)
			assert_has(source, 'VectorFile.new("%s")' % file_name, state)
			var listed: Array = states[state]
			for section: String in listed:
				assert_has(source, 'cases("%s")' % section, state)


func test_a_pending_section_waits_for_a_module_of_lib_domain() -> void:
	var modules := DirAccess.get_directories_at(ReferenceFiles.repo_root().path_join(LIB_DOMAIN))
	assert_has(modules, "resource")
	for file_name: String in VectorRegistry.FILES:
		var states: Dictionary = VectorRegistry.FILES[file_name]
		for state: String in states:
			if state.begins_with("res://"):
				continue
			assert_true(state.begins_with(VectorRegistry.PENDING), state)
			assert_has(modules, VectorRegistry.pending_module(state), "%s: %s" % [file_name, state])


func test_tells_a_section_listed_twice_or_nowhere() -> void:
	assert_eq(
		VectorRegistry.states_of("units", "boost"),
		PackedStringArray([VectorRegistry.PENDING + "fight"])
	)
	assert_eq(VectorRegistry.states_of("units", "morale"), PackedStringArray())
	assert_eq(VectorRegistry.states_of("songs", "boost"), PackedStringArray())
	assert_eq(VectorRegistry.pending_module("pending: fight"), "fight")
	assert_eq(VectorRegistry.pending_module("res://domain/x_test.gd"), "")


func _vector_files() -> PackedStringArray:
	var names := PackedStringArray()
	for file: String in DirAccess.get_files_at(ReferenceFiles.vectors_dir()):
		if file.ends_with(".json"):
			names.append(file.trim_suffix(".json"))
	return names
