extends TestCase
## A ported rule draws, shuffles, sorts and raises through domain/dart, never
## through Godot's own generator, sort or `pow`, which give another game (see
## dart/README.md). This reads every rule of domain/ for the calls a text
## search can tell; `%` and `/` between whole numbers are left to the review.

const DOMAIN := "res://domain"
const DART := "res://domain/dart/"

## What a rule must not write, and what it writes instead.
const FORBIDDEN := {
	"\\brand(i|f|fn|i_range|f_range|omize)\\s*\\(": "DartRandom",
	"\\bRandomNumberGenerator\\b": "DartRandom",
	"\\.pick_random\\s*\\(": "DartRandom.next_int",
	"(?<!\\bDartRandom)(?<!\\bTurnOrder)\\.shuffle\\s*\\(": "DartRandom.shuffle",
	"\\.sort_custom\\s*\\(": "DartSort.sort",
	"\\bposmod\\s*\\(": "DartMath.modulo",
	"\\bpow\\s*\\(|\\*\\*": "DartMath.int_pow or round_times_power",
}


func test_no_rule_calls_what_gives_another_game() -> void:
	var files := _rules(DOMAIN)
	for file: String in files:
		var found := _forbidden_in(FileAccess.get_file_as_string(file))
		assert_eq(found, PackedStringArray(), file)


func test_reads_the_rules_but_not_the_tests_nor_the_dart_layer() -> void:
	var files := _rules(DOMAIN)
	for file: String in files:
		assert_false(file.begins_with(DART), file)
		assert_false(file.ends_with("_test.gd"), file)
	assert_has(_rules(DART.trim_suffix("/"), ""), DART + "dart_random.gd")


func test_tells_each_forbidden_call() -> void:
	var lines := {
		"var die := randi() % 6": "DartRandom",
		"var chance := randf ()": "DartRandom",
		"return randi_range(1, 6)": "DartRandom",
		"randomize()": "DartRandom",
		"var dice := RandomNumberGenerator.new()": "DartRandom",
		"var target: Unit = units.pick_random()": "DartRandom.next_int",
		"cells.shuffle()": "DartRandom.shuffle",
		"posts.sort_custom(by_level)": "DartSort.sort",
		"return posmod(turn, 4)": "DartMath.modulo",
		"var factor := pow(1.6, step)": "DartMath.int_pow or round_times_power",
		"var size := 2 ** level": "DartMath.int_pow or round_times_power",
	}
	for line: String in lines:
		assert_eq(_forbidden_in("func f() -> void:\n\t%s\n" % line).size(), 1, line)
		assert_has(_forbidden_in(line)[0], lines[line], line)


func test_lets_the_dart_layer_and_the_comments_through() -> void:
	var source := "\n".join(PackedStringArray([
		"## Never randi() nor cells.shuffle(): see dart/README.md.",
		"func f(random: DartRandom, cells: Array, turns: Array[int]) -> int:",
		"\tDartRandom.shuffle(cells, random)  # not Array.shuffle()",
		"\tvar order := TurnOrder.shuffle(players, monsters, random)",
		"\tDartSort.sort(cells, by_level)",
		"\tturns.sort()",
		"\tvar operand := DartMath.int_pow(2, 10) * DartMath.modulo(-7, 3)",
		"\treturn random.next_int(6) + operand",
	]))
	assert_eq(_forbidden_in(source), PackedStringArray())


## One line per forbidden call of the source: its line number, the call and
## what to write instead.
func _forbidden_in(source: String) -> PackedStringArray:
	var found := PackedStringArray()
	var lines := source.split("\n")
	for index: int in lines.size():
		var code := lines[index].get_slice("#", 0)
		for pattern: String in FORBIDDEN:
			var call := RegEx.create_from_string(pattern).search(code)
			if call != null:
				found.append("line %d: %s, write %s" % [
					index + 1, call.get_string().strip_edges(), FORBIDDEN[pattern]
				])
	return found


## The scripts under the folder that are no test, the Dart layer left out.
func _rules(folder: String, left_out := DART) -> PackedStringArray:
	var files := PackedStringArray()
	for file_name: String in DirAccess.get_files_at(folder):
		if file_name.ends_with(".gd") and not file_name.ends_with("_test.gd"):
			files.append(folder.path_join(file_name))
	for sub: String in DirAccess.get_directories_at(folder):
		var path := folder.path_join(sub)
		if left_out.is_empty() or not (path + "/").begins_with(left_out):
			files.append_array(_rules(path, left_out))
	return files
