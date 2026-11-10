extends TestCase
## test/domain/history/entries/collect_entry_test.dart: the line of a
## treasure collected.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_collect_entry_keeps_the_target_coordinates() -> void:
	var entry := CollectEntry.new(8, 2, 4, {PEARL: 5})
	assert_eq(entry.category, HistoryEntryCategory.Value.COLLECT)
	assert_eq(entry.target_x, 2)
	assert_eq(entry.target_y, 4)


func test_collect_entry_gains_map_preserves_all_resource_types_and_quantities() -> void:
	var gains: Dictionary[ResourceType.Value, int] = {
		ALGAE: 10, CORAL: 20, ORE: 30, ENERGY: 40, PEARL: 2,
	}
	var entry := CollectEntry.new(1, 1, 1, gains)
	assert_eq(entry.gains, gains)
	assert_eq(entry.gains[PEARL], 2)
	assert_eq(entry.gains.size(), 5)


## Not in the Dart file: the gains keep the order they were given in, which
## the snapshot writes.
func test_keeps_the_gains_in_their_order() -> void:
	var entry := CollectEntry.new(3, 0, 0, {PEARL: 1, ALGAE: 4})
	assert_eq(entry.turn, 3)
	assert_eq(entry.gains.keys(), [PEARL, ALGAE])
