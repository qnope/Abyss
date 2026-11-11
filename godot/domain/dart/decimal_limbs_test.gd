extends TestCase
## Not in the Dart SDK: DecimalLimbs holds whole numbers beyond 64 bits, and
## DoubleInterval bounds the reals that read back as a double.


func test_writes_and_scales_a_number_beyond_64_bits() -> void:
	var limbs := DecimalLimbs.of(123456789012345678)
	DecimalLimbs.scale(limbs, 10, 20)

	assert_eq(DecimalLimbs.text_of(limbs), "12345678901234567800000000000000000000")
	assert_eq(DecimalLimbs.text_of(DecimalLimbs.of(0)), "0")


func test_compares_by_size_then_from_the_top_limb() -> void:
	var big := DecimalLimbs.of(2000000000)
	DecimalLimbs.scale(big, 2, 40)
	var same := DecimalLimbs.of(2000000000)
	DecimalLimbs.scale(same, 2, 40)

	assert_eq(DecimalLimbs.compare(big, same), 0)
	assert_eq(DecimalLimbs.compare(DecimalLimbs.of(7), big), -1)
	assert_eq(DecimalLimbs.compare(big, DecimalLimbs.of(7)), 1)
	assert_eq(DecimalLimbs.compare(DecimalLimbs.of(1000000001), DecimalLimbs.of(2000000000)), -1)


func test_bounds_a_double_halfway_to_its_neighbours() -> void:
	# 2^53 + 2: its neighbours are 2^53 and 2^53 + 4, its mantissa odd.
	var interval := DoubleInterval.new(9007199254740994.0)

	assert_eq(interval.place("9007199254740994", 0), 0)
	assert_eq(interval.place("9007199254740993", 0), -1, "halfway, to the even 2^53")
	assert_eq(interval.place("9007199254740995", 0), 1, "halfway, to the even 2^53 + 4")
	assert_eq(DoubleInterval.new(9007199254740992.0).place("9007199254740993", 0), 0, "even, halfway up")
