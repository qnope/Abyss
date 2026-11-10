extends TestCase
## Not in the Dart files: a plain `Random(seed)` and a `SeededRandom(seed)`
## draw the same; only a rule that asks `is SeededRandom` (the seed of the
## fight of AnnounceAttackAction) tells them apart, through `is_seeded`.


func test_a_plain_generator_draws_as_a_seeded_one_and_says_it_is_not() -> void:
	var plain := DartRandom.new(7, false)
	var seeded := DartRandom.new(7)
	assert_true(seeded.is_seeded)
	assert_false(plain.is_seeded)
	assert_eq(plain.initial_seed, 7)
	for _draw: int in 20:
		assert_eq(plain.next_int(1000), seeded.next_int(1000))


func test_a_generator_without_a_seed_is_no_seeded_random() -> void:
	assert_false(DartRandom.unseeded().is_seeded)
	assert_true(SeededRandom.fresh().is_seeded)
