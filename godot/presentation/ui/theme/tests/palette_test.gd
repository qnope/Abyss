extends TestCase
## Every named colour of the Flutter theme has its GDScript constant, with
## the same value: flutter_palette.json is written from the Dart sources by
## tool/flutter_palette.py, so a change on the Dart side fails here until
## the port follows.

const FIXTURE := "res://presentation/ui/theme/tests/flutter_palette.json"
## The classes that hold nothing but Flutter's constants: each of their
## colours must be one of the fixture.
const PALETTES: Array[String] = ["AbyssColors", "FactionColors", "AbyssArmyColors"]

var _fixture: Dictionary


func before_each() -> void:
	_fixture = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))


func test_the_fixture_holds_the_flutter_theme() -> void:
	assert_eq(_fixture.keys(), [
		"AbyssColors", "FactionColors", "AbyssArmyColors", "AbyssSegmentedTheme"
	])


func test_every_flutter_constant_has_its_port() -> void:
	for owner: String in _fixture:
		var constants := _constants_of(owner)
		var expected: Dictionary = _fixture[owner]
		for name: String in expected:
			var where := "%s.%s" % [owner, name]
			assert_has(constants, name, where)
			if constants.has(name):
				assert_eq(_dart(constants[name]), expected[name], where)


func test_the_palettes_hold_no_colour_of_their_own() -> void:
	for owner in PALETTES:
		var expected: Dictionary = _fixture[owner]
		var constants := _constants_of(owner)
		for name: String in constants:
			if constants[name] is Color or constants[name] is Array:
				assert_has(expected, name, "%s.%s is not in Flutter" % [owner, name])


func test_reads_a_colour_as_dart_writes_it() -> void:
	assert_eq(_dart(Color("42a5f566")), "#6642A5F5")
	assert_eq(_dart([Color.WHITE] as Array[Color]), ["#FFFFFFFF"])
	assert_eq(_dart(0.5), 0.5)


func test_dims_a_colour_by_half_its_opacity() -> void:
	assert_eq(AbyssColors.dimmed(Color(1, 0, 0, 0.8)), Color(1, 0, 0, 0.4))


func test_darkens_a_squad_hue_towards_the_abyss_for_its_pennant() -> void:
	assert_eq(
		AbyssArmyColors.pennant(AbyssArmyColors.HARPOONIST),
		AbyssArmyColors.HARPOONIST.lerp(AbyssColors.ABYSS_BLACK, 0.55)
	)


## The constants of the global class [param name], none when it is missing.
func _constants_of(name: String) -> Dictionary:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if entry["class"] == name:
			var path: String = entry["path"]
			return (load(path) as Script).get_script_constant_map()
	fail("no class %s" % name)
	return {}


## [param value] as the fixture writes it: "#AARRGGBB" for a colour.
func _dart(value: Variant) -> Variant:
	if value is Color:
		var color: Color = value
		return "#%08X" % color.to_argb32()
	if value is Array:
		var items: Array = value
		return items.map(_dart)
	return value
