class_name AtomicFile
extends RefCounted
## A text file replaced in one go: the text is written whole to `<path>.tmp`
## beside it, then renamed over the file. A crash or a full disk while
## writing leaves the file as it was, at worst with a `.tmp` beside it that
## the next write replaces.

const TEMP_SUFFIX := ".tmp"


## Writes `text` to `path`, creating its folder; OK, or the error met, the
## file then left untouched.
static func write(path: String, text: String) -> Error:
	var folder := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if folder != OK:
		return folder
	var temp := path + TEMP_SUFFIX
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var stored := file.store_string(text)
	file.close()
	return DirAccess.rename_absolute(temp, path) if stored else ERR_FILE_CANT_WRITE


## The text of `path`, or null when it cannot be read.
static func read(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	return null if file == null else file.get_as_text()
