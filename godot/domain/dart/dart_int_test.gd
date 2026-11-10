extends TestCase
## DartInt.try_parse reads a text as the Dart VM's `int.tryParse` does. No
## vector holds it yet: each answer below is what Dart 3.13 gave to the same
## text (`dart run`), null where it gave null.

const MAX := 9223372036854775807
const MIN := -9223372036854775807 - 1


func test_reads_the_whole_numbers_dart_reads() -> void:
	var read := {
		"0": 0, "7": 7, "12": 12, "-1": -1, "+3": 3, "00012": 12, "-0": 0,
		"000000000000000000000000000001": 1,
		"9223372036854775807": MAX, "-9223372036854775808": MIN,
	}
	for text: String in read:
		assert_eq(DartInt.try_parse(text), read[text], text)


func test_leaves_out_the_white_space_around_as_dart_does() -> void:
	var read := {
		" 4": 4, "5 ": 5, " 6 ": 6, "\t7\n": 7, " 5": 5, "5 ": 5,
		"　5": 5, "\u000b3": 3, "\u00853": 3, " 3": 3, "﻿3": 3,
		" -2 ": -2, " +8  ": 8,
	}
	for text: String in read:
		assert_eq(DartInt.try_parse(text), read[text], text.c_escape())


func test_reads_a_hexadecimal_number_after_0x() -> void:
	var read := {
		"0x1F": 31, "0X1f": 31, "-0x10": -16, "+0x10": 16, "0x0": 0, "0x000a": 10,
		"0x7FFFFFFFFFFFFFFF": MAX,
		# Up to 64 bits, read as the bits of the number.
		"0xFFFFFFFFFFFFFFFF": -1, "0x8000000000000000": MIN,
		"0x0000FFFFFFFFFFFFFFFF": -1, "-0x8000000000000000": MIN,
	}
	for text: String in read:
		assert_eq(DartInt.try_parse(text), read[text], text)


func test_reads_nothing_from_any_other_text() -> void:
	var refused := [
		"", " ", "x", "1x", "1.0", "1e3", "--1", "+-1", "+", "-", "0x", "1 2", "１", "٣",
		"1_000", "0b11", "0o7", "- 1", "0x-1", "0x 1", "-0x", "0xg", "a", "​3",
	]
	for text: String in refused:
		assert_null(DartInt.try_parse(text), text.c_escape())


func test_reads_nothing_beyond_64_bits() -> void:
	var refused := [
		"9223372036854775808", "-9223372036854775809", "99999999999999999999",
		"0x10000000000000000", "-0xFFFFFFFFFFFFFFFF", "-0x8000000000000001",
	]
	for text: String in refused:
		assert_null(DartInt.try_parse(text), text)
