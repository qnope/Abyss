extends TestCase
## test/domain/map/map_generator_golden_test.dart: fingerprints of the maps
## a single player gets, captured in Dart before maps learned to hold
## several bases: a lone player's map must never change. Level 3 was
## recaptured when the volcano grew to a 2x2 footprint.

## The fingerprints of levels 1, 2 and 3, then the base of level 1, by seed.
const GOLDEN: Dictionary[int, Array] = {
	1: [1571951233, 2055003048, 2750926549, 12, 10],
	42: [396363621, 1190823070, 1014633587, 10, 11],
	123: [3572676688, 3728283768, 33725388, 9, 8],
	777: [3614134476, 1368645896, 1963665531, 11, 8],
	2024: [198791399, 3666432626, 2268720082, 10, 11],
	99999: [127208571, 1042239294, 3202106484, 8, 11],
	31337: [1263256019, 1156572413, 3428174847, 10, 10],
	2147483632: [1792596019, 1782540289, 3086644629, 10, 10],
}


## Dart generates one test per seed.
func test_single_player_golden_maps_each_seed_gives_the_same_three_levels() -> void:
	for seed_of_map: int in GOLDEN:
		var l1 := MapGenerator.generate(seed_of_map)
		var l2 := MapGenerator.generate(seed_of_map + 1, 2, MapSamples.passages_of(l1.map))
		var l3 := MapGenerator.generate(seed_of_map + 2, 3, MapSamples.passages_of(l2.map))
		var found := [
			MapSamples.fingerprint(l1.map),
			MapSamples.fingerprint(l2.map),
			MapSamples.fingerprint(l3.map),
			l1.base_x,
			l1.base_y,
		]
		assert_eq(found, GOLDEN[seed_of_map], "seed %d" % seed_of_map)
