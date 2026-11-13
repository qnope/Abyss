extends TestCase
## What the exports leave out (godot/export_presets.cfg): the models no code
## loads, which only weigh on the download of the web page. A model that a
## script loads must never be among them, or the game would find it missing
## in an export and not in the editor.

const PRESETS := "res://export_presets.cfg"
const FOLDER := "assets/models/"
## The folders whose scripts and scenes the exports leave out.
const NOT_EXPORTED: Array[String] = ["tool", "tests", ".godot", "addons"]


func test_leaves_out_the_unused_models_in_every_preset() -> void:
	var presets := ConfigFile.new()
	assert_eq(presets.load(PRESETS), OK)
	var excluded := _excluded_models()
	assert_true(excluded.size() >= 6, "the three resources, the leviathan, the probe and the swatches")
	for section in presets.get_sections():
		if section.ends_with(".options"):
			continue
		var filter: String = presets.get_value(section, "exclude_filter", "")
		for model in excluded:
			assert_true(_matches(filter, FOLDER + model),
				"%s leaves out %s" % [presets.get_value(section, "name", section), model])


func test_no_script_nor_scene_of_the_game_loads_a_model_left_out() -> void:
	var sources := _sources("res://")
	for model in _excluded_models():
		for path in sources:
			assert_false(sources[path].contains(model), "%s names %s, which the exports leave out" % [path, model])


## The glb of assets/models/ the first preset leaves out, by file name.
func _excluded_models() -> Array[String]:
	var presets := ConfigFile.new()
	presets.load(PRESETS)
	var filter: String = presets.get_value("preset.0", "exclude_filter", "")
	var found: Array[String] = []
	for file in DirAccess.get_files_at("res://" + FOLDER):
		if file.ends_with(".glb") and _matches(filter, FOLDER + file):
			found.append(file)
	return found


static func _matches(filter: String, path: String) -> bool:
	for pattern in filter.split(","):
		if path.match(pattern.strip_edges()):
			return true
	return false


## The text of every script and scene under [param folder] the exports keep.
static func _sources(folder: String) -> Dictionary[String, String]:
	var found: Dictionary[String, String] = {}
	for dir in DirAccess.get_directories_at(folder):
		if not NOT_EXPORTED.has(dir):
			found.merge(_sources(folder.path_join(dir)))
	for file in DirAccess.get_files_at(folder):
		if (file.ends_with(".gd") or file.ends_with(".tscn")) and not file.ends_with("_test.gd"):
			found[folder.path_join(file)] = FileAccess.get_file_as_string(folder.path_join(file))
	return found
