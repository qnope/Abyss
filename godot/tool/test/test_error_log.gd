class_name TestErrorLog
extends Logger
## Collects the engine and script errors logged while a test runs, so that a
## test hitting one fails instead of passing. GDScript has no exceptions: a
## function that hits a script error returns at once and its caller goes on,
## so the runner learns of the error only through the engine's log.

var _errors: PackedStringArray = PackedStringArray()
var _mutex: Mutex = Mutex.new()


func _log_error(
	_function: String, file: String, line: int, code: String, rationale: String,
	_editor_notify: bool, error_type: int, _script_backtraces: Array[ScriptBacktrace]
) -> void:
	if error_type == ERROR_TYPE_WARNING:
		return
	var text := rationale if not rationale.is_empty() else code
	_mutex.lock()
	_errors.append("%s (%s:%d)" % [text, file, line])
	_mutex.unlock()


## What fails a test once each part it expected has let one error holding it
## pass: the other errors, then a line per expected error that never came.
static func unexpected(
	errors: PackedStringArray, expected: PackedStringArray
) -> PackedStringArray:
	var left := errors.duplicate()
	var missing := PackedStringArray()
	for part: String in expected:
		var index := _index_holding(left, part)
		if index < 0:
			missing.append('expected an error holding "%s", none was logged' % part)
		else:
			left.remove_at(index)
	left.append_array(missing)
	return left


## The errors logged so far, in order.
func errors() -> PackedStringArray:
	_mutex.lock()
	var copy := _errors.duplicate()
	_mutex.unlock()
	return copy


static func _index_holding(errors: PackedStringArray, part: String) -> int:
	for index: int in errors.size():
		if errors[index].contains(part):
			return index
	return -1
