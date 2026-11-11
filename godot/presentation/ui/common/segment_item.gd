class_name SegmentItem
extends RefCounted
## One choice of a [SegmentedBar]: its value, the label shown with a detail
## below it, and what a screen reader says of it (lib/.../segmented_bar.dart,
## Segment).

var value: Variant
var label: String
var detail: String
var semantics_label: String


func _init(item_value: Variant, item_label: String, spoken: String, item_detail := "") -> void:
	value = item_value
	label = item_label
	semantics_label = spoken
	detail = item_detail
