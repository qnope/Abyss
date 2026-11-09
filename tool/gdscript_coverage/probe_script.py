"""The CoverageProbe class added to the instrumented copy, and its dump."""

TEMPLATE = """class_name CoverageProbe
extends RefCounted
## Written into the instrumented copy by tool/godot_coverage.py: counts how
## often each probe runs, a slot per line number of each instrumented script.

const OFFSETS: Array[int] = [%(offsets)s]
const SIZE := %(size)d

static var _hits: PackedInt64Array = _zeros()


static func hit(file: int, line: int) -> void:
	_hits[OFFSETS[file] + line] += 1


## Writes every slot's hits on one line, as the test runner ends.
static func dump(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var counts := PackedStringArray()
	for count: int in _hits:
		counts.append(str(count))
	file.store_string(" ".join(counts))
	return OK


static func _zeros() -> PackedInt64Array:
	var zeros := PackedInt64Array()
	zeros.resize(SIZE)
	return zeros
"""


def probe_script(line_counts):
    """The class for files of these line counts, in file index order."""
    offsets, size = _layout(line_counts)
    return TEMPLATE % {"offsets": ", ".join(map(str, offsets)), "size": size}


def read_hits(dump, line_counts):
    """Each file's hits, indexed by line number (slot 0 is unused)."""
    counts = [int(word) for word in dump.split()]
    offsets, size = _layout(line_counts)
    if len(counts) != size:
        raise ValueError("%d slots expected, %d found" % (size, len(counts)))
    return [counts[offset:offset + lines + 1] for offset, lines in zip(offsets, line_counts)]


def _layout(line_counts):
    offsets, size = [], 0
    for lines in line_counts:
        offsets.append(size)
        size += lines + 1
    return offsets, size
