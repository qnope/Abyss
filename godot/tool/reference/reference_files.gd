class_name ReferenceFiles
extends RefCounted
## Where the tests find `reference/`, which lies outside the Godot project,
## at the root of the repository. That root is the folder above `res://`,
## unless ABYSS_REPO_ROOT names it: tool/godot_coverage.py does, since it
## runs the tests on a copy of the project in a temporary folder.

const ROOT_VARIABLE := "ABYSS_REPO_ROOT"


static func repo_root() -> String:
	var given := OS.get_environment(ROOT_VARIABLE)
	if not given.is_empty():
		return given
	return ProjectSettings.globalize_path("res://").path_join("..").simplify_path()


static func vectors_dir() -> String:
	return repo_root().path_join("reference/vectors")


## The path of `reference/vectors/<file_name>.json`.
static func vector_path(file_name: String) -> String:
	return vectors_dir().path_join(file_name + ".json")


## The text of a file of the repository by its path from the root
## (`scenarios/replays/victoire-tour-85.json`), "" when there is none: the
## reader `PlanLibrary.use_reader` takes.
static func text_of(path: String) -> String:
	return FileAccess.get_file_as_string(repo_root().path_join(path))
