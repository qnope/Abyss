class_name HistoryFilterChips
extends RefreshingPanel
## The row of chips that picks what the history shows, one per
## [enum HistoryFilter.Value] (lib/presentation/widgets/history/
## history_filter_chips.dart). The lit one is [member current]; a touch on
## another tells [signal changed]. The names follow the language.

## The player picked [param filter].
signal changed(filter: HistoryFilter.Value)

var current: HistoryFilter.Value
var chips: ChipRow


func _init(current_ := HistoryFilter.Value.ALL) -> void:
	current = current_
	super()
	var items: Array[SegmentItem] = []
	for filter: HistoryFilter.Value in HistoryFilter.Value.values():
		items.append(SegmentItem.new(filter, "", ""))
	chips = ChipRow.new(items, current)
	chips.chosen.connect(_on_chosen)
	add_child(chips)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the chips are made.
	if chips == null:
		return
	for filter: HistoryFilter.Value in HistoryFilter.Value.values():
		var button := chips.button(filter)
		button.text = HistoryFilter.label(filter)
		button.accessibility_name = button.text


## Lights [param filter] without telling it.
func select(filter: HistoryFilter.Value) -> void:
	current = filter
	chips.select(filter)


func _on_chosen(filter: Variant) -> void:
	current = filter
	changed.emit(current)
