class_name TestDiscovery
extends RefCounted
## Finds the test files to run: every `*_test.gd` under the given folders, or
## the given files as they are. Paths are `res://` or relative to the project.
## Walking a folder skips hidden folders (res://.godot) and the runner's
## fixtures, which run only when their folder is asked for itself.

const SUFFIX := "_test.gd"
const FIXTURES := "res://tool/test/fixtures"


## With no paths, every test file of the project.
static func find(paths: PackedStringArray) -> PackedStringArray:
	var files := PackedStringArray()
	for path: String in (paths if not paths.is_empty() else PackedStringArray(["res://"])):
		var resolved := resolve(path)
		if DirAccess.dir_exists_absolute(resolved):
			_walk(resolved, files)
		else:
			files.append(resolved)
	return files


static func resolve(path: String) -> String:
	if path == "res://":
		return path
	var relative := path.trim_prefix("res://").trim_prefix("./").trim_suffix("/")
	return "res://" + relative


static func _walk(folder: String, files: PackedStringArray) -> void:
	var names := DirAccess.get_files_at(folder)
	names.sort()
	for file_name: String in names:
		if file_name.ends_with(SUFFIX):
			files.append(folder.path_join(file_name))
	var folders := DirAccess.get_directories_at(folder)
	folders.sort()
	for folder_name: String in folders:
		var sub := folder.path_join(folder_name)
		if not folder_name.begins_with(".") and sub != FIXTURES:
			_walk(sub, files)
