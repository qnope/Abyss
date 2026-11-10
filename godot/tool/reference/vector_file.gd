class_name VectorFile
extends RefCounted
## One file of reference/vectors: the inputs of a piece of the Dart rules and
## what they answered, which the port must answer too. A test reads the cases
## of a section and calls its own code with each. A file or a section that is
## missing or empty logs an error, which fails the test: never a silent skip.

## The name of the file, without `.json`.
var name: String

var _api: Dictionary = {}
var _sections: Dictionary = {}


## Reads `<folder>/<file_name>.json`, by default from reference/vectors.
func _init(file_name: String, folder := ReferenceFiles.vectors_dir()) -> void:
	name = file_name
	var path := folder.path_join(file_name + ".json")
	if not FileAccess.file_exists(path):
		push_error("No vector file %s (dart run bin/export_vectors.dart writes them)" % path)
		return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		push_error("%s is not a vector file" % path)
		return
	var content: Dictionary = json.data
	_api = content.get("api", {})
	_sections = content.get("sections", {})


func section_names() -> PackedStringArray:
	return PackedStringArray(_sections.keys())


## The Dart call behind every case of the section.
func api(section: String) -> String:
	if not _has(section):
		return ""
	return _api.get(section, "")


## The cases of the section, their values decoded (see VectorValues).
func cases(section: String) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	if not _has(section):
		return found
	var raw: Array = _sections[section]
	for case: Variant in raw:
		found.append(VectorValues.decode(case))
	if found.is_empty():
		push_error('The section "%s" of the vector file "%s" has no case' % [section, name])
	return found


func _has(section: String) -> bool:
	if not _sections.has(section):
		push_error('No section "%s" in the vector file "%s"' % [section, name])
		return false
	return true
