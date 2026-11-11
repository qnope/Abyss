class_name SimulateOptions
extends RefCounted
## The options of `bin/simulate.dart`, read as its `_parse` reads them:
## every `--key` takes the next argument as its value unless that one is
## another option, then holds "" (`--json`, `--verbose`); any other
## argument is left out. A value Dart's `int.parse`, `double.parse` or
## `Difficulty.values.byName` would throw on sets `error` and the default.

var values: Dictionary[String, String] = {}
## What Dart would have thrown on, "" when nothing.
var error := ""


func _init(args: PackedStringArray) -> void:
	var i := 0
	while i < args.size():
		if args[i].begins_with("--"):
			var has_value := i + 1 < args.size() and not args[i + 1].begins_with("--")
			values[args[i].substr(2)] = args[i + 1] if has_value else ""
			if has_value:
				i += 1
		i += 1


func has(key: String) -> bool:
	return values.has(key)


func text(key: String, otherwise: String) -> String:
	return values.get(key, otherwise)


## `int.parse(options[key] ?? otherwise)`.
func whole(key: String, otherwise: int) -> int:
	var parsed: Variant = DartInt.try_parse(text(key, str(otherwise)))
	if parsed == null:
		_refuse("--%s: not a whole number: %s" % [key, text(key, "")])
		return otherwise
	return parsed


## `double.parse(options[key] ?? otherwise)`. Godot's `to_float` reads a
## text of up to 15 digits as Dart does (domain/dart/README.md).
func decimal(key: String, otherwise: float) -> float:
	var given := text(key, "")
	if not has(key):
		return otherwise
	if not given.is_valid_float():
		_refuse("--%s: not a number: %s" % [key, given])
		return otherwise
	return given.to_float()


## `Difficulty.values.byName(options['difficulty'] ?? 'normal')`.
func difficulty() -> Difficulty.Value:
	var named: Variant = DartEnum.by_name(Difficulty.Value, text("difficulty", "normal"))
	if named == null:
		_refuse("--difficulty: no difficulty named %s" % text("difficulty", ""))
		return Difficulty.Value.NORMAL
	return named


## `ReplayVariant` of the options of a replay (`--new-map`, `--army`...).
func variant() -> ReplayVariant:
	return ReplayVariant.new(
		not has("new-map"), not has("new-dice"), decimal("army", 1.0), whole("jitter", 0),
		decimal("stretch", 1.0), whole("patience", 6), has("defends"),
	)


func _refuse(message: String) -> void:
	if error.is_empty():
		error = message
