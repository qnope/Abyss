extends TestCase
## Not in the Dart tests, which have none for lib/domain/replay/
## seeded_random.dart: a `SeededRandom(seed)` is a DartRandom (its draws and
## its seed are held by the seededRandom section of dart_random.json, in
## dart_random_test.gd); its `fresh()` draws the seed as Dart does.


func test_a_fresh_generator_draws_its_seed_below_2_to_the_31_minus_1() -> void:
	for _draw: int in 200:
		var random := SeededRandom.fresh()
		assert_true(random.initial_seed >= 0 and random.initial_seed < 0x7FFFFFFF)


func test_a_fresh_generator_draws_as_any_of_its_seed() -> void:
	var random := SeededRandom.fresh()
	var twin := DartRandom.new(random.initial_seed)
	for _draw: int in 20:
		assert_eq(random.next_int(1000), twin.next_int(1000))
