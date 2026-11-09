extends RefCounted
## Stands for the CoverageProbe class that tool/godot_coverage.py adds to its
## instrumented copy of the project: records where it was asked to dump.

const UNWRITABLE := "/unwritable/hits.txt"

static var dumped_to: String = ""


static func dump(path: String) -> Error:
	if path == UNWRITABLE:
		return ERR_FILE_CANT_WRITE
	dumped_to = path
	return OK
