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


## The errors logged so far, in order.
func errors() -> PackedStringArray:
	_mutex.lock()
	var copy := _errors.duplicate()
	_mutex.unlock()
	return copy
