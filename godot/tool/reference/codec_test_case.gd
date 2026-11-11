class_name CodecTestCase
extends TestCase
## A test of a codec of `data/save/`: an object written, turned into the
## JSON text of a save, parsed and read back must be the object written, as
## the snapshot of its class sees it (`ClassSnapshot`, every field the
## state holds), and reading leaves no problem.

## The human the snapshots write as `human`.
const HUMAN := "h"


## `read(write(value))` through the text of a save; returns what was read.
func assert_round_trip(snapshot: ClassSnapshot, write: Callable, read: Callable, value: Object) -> Object:
	var text := JSON.stringify(write.call(value), "", false)
	var r := SaveReader.new()
	var loaded: Object = read.call(r, JSON.parse_string(text))
	assert_eq(r.problem, "", text.left(200))
	var ids := PlayerIds.new(HUMAN)
	var expected := CanonicalWriter.write(snapshot.of(value, ids))
	assert_eq(CanonicalWriter.write(snapshot.of(loaded, ids)), expected, snapshot.dart_class)
	return loaded


## The problem `read` notes on the JSON `text`.
func problem_of(read: Callable, text: String) -> String:
	var r := SaveReader.new()
	read.call(r, JSON.parse_string(text))
	return r.problem
