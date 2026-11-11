extends TestCase
## IcuFormat on messages written here; the game's own messages are held
## against Flutter's strings in texts_test.gd.

const COUNT := "{n, plural, =0{none} one{{n} cat} other{{n} cats}}"


func test_writes_the_arguments_into_the_text() -> void:
	assert_eq(IcuFormat.format("Turn {turn} of {max}: {name}", {"turn": 3, "max": 9, "name": "Zed"}, "en"), "Turn 3 of 9: Zed")
	assert_eq(IcuFormat.format("no argument at all", {}, "en"), "no argument at all")
	assert_eq(IcuFormat.format("", {}, "en"), "")


func test_keeps_apostrophes_quotes_and_a_stray_closing_brace_as_text() -> void:
	assert_eq(IcuFormat.format("l'Amiral \"x\" }", {}, "fr"), "l'Amiral \"x\" }")


func test_an_exact_case_wins_over_the_category() -> void:
	assert_eq(IcuFormat.format(COUNT, {"n": 0}, "fr"), "none")
	assert_eq(IcuFormat.format(COUNT, {"n": 0}, "en"), "none")
	var exact := "{n, plural, =1{exactly one} one{one} other{many}}"
	assert_eq(IcuFormat.format(exact, {"n": 1}, "fr"), "exactly one")


func test_picks_the_category_of_the_language() -> void:
	var plain := "{n, plural, one{{n} cat} other{{n} cats}}"
	assert_eq(IcuFormat.format(plain, {"n": 0}, "fr"), "0 cat")
	assert_eq(IcuFormat.format(plain, {"n": 0}, "en"), "0 cats")
	assert_eq(IcuFormat.format(plain, {"n": 1}, "es"), "1 cat")
	assert_eq(IcuFormat.format(plain, {"n": 2}, "fr"), "2 cats")
	assert_eq(IcuFormat.format(COUNT, {"n": 7}, "en"), "7 cats")


func test_a_zero_case_is_tried_before_the_category() -> void:
	var zero := "{n, plural, zero{nothing} one{one} other{many}}"
	assert_eq(IcuFormat.format(zero, {"n": 0}, "fr"), "nothing")
	assert_eq(IcuFormat.format(zero, {"n": 1}, "fr"), "one")
	assert_eq(IcuFormat.format(zero, {"n": 2}, "en"), "many")


func test_selects_by_the_text_of_the_argument() -> void:
	var select := "{k, select, faille{the Rift} cheminee{the Vent} other{the Core}}"
	assert_eq(IcuFormat.format(select, {"k": "faille"}, "en"), "the Rift")
	assert_eq(IcuFormat.format(select, {"k": "cheminee"}, "en"), "the Vent")
	assert_eq(IcuFormat.format(select, {"k": "noyau"}, "en"), "the Core")


func test_reads_text_around_nested_and_repeated_arguments() -> void:
	var text := "Take {post, select, a{an {n, plural, one{{n} unit} other{{n} units}}} other{none}} and {m, plural, one{{m} more} other{{m} others}} of {post}."
	assert_eq(IcuFormat.format(text, {"post": "a", "n": 1, "m": 3}, "en"), "Take an 1 unit and 3 others of a.")
	assert_eq(IcuFormat.format(text, {"post": "z", "n": 1, "m": 1}, "en"), "Take none and 1 more of z.")


func test_a_whole_float_reads_as_the_int_json_hands_over() -> void:
	assert_eq(IcuFormat.format("{n, plural, one{{n} cat} other{{n} cats}} {n}", {"n": 2.0}, "en"), "2 cats 2")


func test_an_argument_that_is_missing_is_an_error_and_writes_nothing() -> void:
	expect_error("no argument \"who\"")
	assert_eq(IcuFormat.format("Hi {who}!", {}, "en"), "Hi !")
	expect_error("no argument \"n\"")
	assert_eq(IcuFormat.format(COUNT, {}, "en"), "none")


func test_an_unclosed_brace_is_an_error_and_keeps_the_rest_as_text() -> void:
	expect_error("unclosed")
	assert_eq(IcuFormat.format("a {b", {"b": 1}, "en"), "a {b")
