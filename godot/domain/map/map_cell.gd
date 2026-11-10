class_name MapCell
extends RefCounted
## lib/domain/map/map_cell.dart: one cell of a map. Nothing changes a cell:
## the rules put a copy in its place (`copy_with`).

const _FIELDS: Array[String] = [
	"terrain", "content", "lair", "collected_by", "transition_base", "passage_name",
]

var terrain: TerrainType.Value
var content: CellContentType.Value
## The monsters of the cell, or null. A cell keeps the lair it was given
## when its content changes: a lair may lie under any content.
var lair: MonsterLair
## The id of the player who emptied the cell (a String), or null.
var collected_by: Variant
## The post of the cell, or null; kept as the lair is.
var transition_base: TransitionBase
## The code of the post above a passage (a String), or null.
var passage_name: Variant


func _init(
	terrain_: TerrainType.Value,
	content_ := CellContentType.Value.EMPTY,
	lair_: MonsterLair = null,
	collected_by_: Variant = null,
	transition_base_: TransitionBase = null,
	passage_name_: Variant = null,
) -> void:
	terrain = terrain_
	content = content_
	lair = lair_
	collected_by = collected_by_
	transition_base = transition_base_
	passage_name = passage_name_


func is_collected() -> bool:
	return collected_by != null


## `copyWith`: a copy of the cell, the fields named in `changes` (by their
## name here, as "passage_name") replaced. A lair, a collector, a post or a
## passage name given as null becomes null, which Dart tells from a field
## left out by a sentinel; a null terrain or content keeps the field, as
## Dart's `terrain ?? this.terrain`. A name that is no field logs an error.
func copy_with(changes: Dictionary = {}) -> MapCell:
	for field: Variant in changes:
		if not _FIELDS.has(field):
			push_error('MapCell.copy_with: no field "%s"' % field)
	var terrain_: TerrainType.Value = terrain
	if changes.get("terrain") != null:
		terrain_ = changes["terrain"]
	var content_: CellContentType.Value = content
	if changes.get("content") != null:
		content_ = changes["content"]
	var lair_: MonsterLair = changes.get("lair", lair)
	var transition_base_: TransitionBase = changes.get("transition_base", transition_base)
	return MapCell.new(
		terrain_,
		content_,
		lair_,
		changes.get("collected_by", collected_by),
		transition_base_,
		changes.get("passage_name", passage_name),
	)
