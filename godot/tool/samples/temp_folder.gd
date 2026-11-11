class_name TempFolder
extends RefCounted
## A folder of its own under `user://` for a test of the files of `data/`,
## removed with all it holds by `remove()`, which the test calls in its
## `after_each`.

var path: String


func _init() -> void:
	path = "user://test-%s" % UuidV4.generate()


## Removes the folder and everything under it.
func remove() -> void:
	_remove(path)


static func _remove(folder: String) -> void:
	if not DirAccess.dir_exists_absolute(folder):
		return
	for sub: String in DirAccess.get_directories_at(folder):
		_remove(folder.path_join(sub))
	for file: String in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute(folder.path_join(file))
	DirAccess.remove_absolute(folder)
