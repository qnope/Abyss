extends TestCase
## test/domain/reference/digest_rows_test.dart, the group DigestRows. The
## group ReferenceLayout waits for reference_layout.dart, a part of the
## exporter.

var rows: Array[PackedStringArray] = [
	PackedStringArray(["a", "b", "c"]),
	PackedStringArray(["a", "d", "c"]),
	PackedStringArray(["e", "d", "c"]),
	PackedStringArray(["a", "d", "c"]),
]


func test_a_digest_that_did_not_change_since_the_row_before_is_same() -> void:
	assert_eq(DigestRows.compact(rows), [
		PackedStringArray(["a", "b", "c"]),
		PackedStringArray(["=", "d", "="]),
		PackedStringArray(["e", "=", "="]),
		PackedStringArray(["a", "=", "="]),
	] as Array[PackedStringArray])


func test_expand_gives_the_rows_back() -> void:
	assert_eq(DigestRows.expand(DigestRows.compact(rows)), rows)
	assert_eq(DigestRows.expand([]), [] as Array[PackedStringArray])
	assert_eq(DigestRows.compact([]), [] as Array[PackedStringArray])
