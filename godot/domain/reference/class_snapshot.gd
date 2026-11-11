class_name ClassSnapshot
extends RefCounted
## lib/domain/reference/class_snapshot.dart: how the objects of one
## persisted class are written in a snapshot, a map with one entry per
## field, named after the Dart field.
##
## It declares what it writes, so a test can compare it with the fields of
## the class and fail when a field is added to the model and forgotten
## here: every field of the state is either in `fields` or in `omitted`,
## with the reason it is left out (snapshot_completeness_test.gd).

## `className`, the name of the Dart class (`class_name` is a keyword).
var dart_class: String
## The fields written, by the name of the Dart field: each a Callable
## taking the object and the PlayerIds, giving a canonical value.
var fields: Dictionary[String, Callable]
## Fields written under another key than their Dart name, which only tells
## how an old save stored them (`savedFallen` is `fallen`).
var renamed: Dictionary[String, String]
## Fields of the class this snapshot does not write, each with the reason.
var omitted: Dictionary[String, String]


func _init(
	dart_class_: String,
	fields_: Dictionary[String, Callable],
	renamed_: Dictionary[String, String] = {},
	omitted_: Dictionary[String, String] = {},
) -> void:
	dart_class = dart_class_
	fields = fields_
	renamed = renamed_
	omitted = omitted_


## The Dart names of the fields written.
func field_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(fields.keys())
	return names


## The key `field` is written under.
func key_of(field: String) -> String:
	return renamed.get(field, field)


func of(value: Object, ids: PlayerIds) -> Dictionary:
	return only(value, ids, null)


## `orNull`: null for a missing object.
func or_null(value: Object, ids: PlayerIds) -> Variant:
	return null if value == null else of(value, ids)


func list_of(values: Array, ids: PlayerIds) -> Array:
	var written: Array = []
	for value: Object in values:
		written.append(of(value, ids))
	return written


## The fields of `value` named in `names` (a set, Dictionary[String, bool]);
## all of them when null.
func only(value: Object, ids: PlayerIds, names: Variant) -> Dictionary:
	var everything := names == null
	var wanted: Dictionary = {} if everything else names
	var written := {}
	for field: String in fields:
		if everything or wanted.has(field):
			written[key_of(field)] = fields[field].call(value, ids)
	return written
