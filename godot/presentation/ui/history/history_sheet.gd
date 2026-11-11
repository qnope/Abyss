class_name HistorySheet
extends ModalPanel
## The player's action log, in a bottom sheet 80 % of the screen high
## (lib/presentation/widgets/history/history_sheet.dart and
## history_sheet_body.dart): the chips of the filters over the cards of the
## entries, the newest first. It takes the entries as they are when it opens
## and its filter starts at "all": closing and reopening it starts over.
##
## A touch on a tappable card opens the report of that entry on the modals
## through [HistoryReports]. Dragging the handle down far
## enough closes it, like a touch outside.

const HEIGHT_SHARE := 0.8
const CHIPS_PADDING := Vector2i(16, 8)
const LIST_PADDING := Vector2i(12, 8)
const GAP := 8
const EMPTY_PADDING := 24

var entries: Array[HistoryEntry]
var handle := SheetDragHandle.new(AbyssCardTheme.DRAG_HANDLE)
var chips := HistoryFilterChips.new()
var list := VBoxContainer.new()
var empty_label := Label.new()
## What shows in the place of the cards when there are none.
var empty_box := MarginContainer.new()
## The cards shown, newest first.
var cards: Array[HistoryEntryCard] = []
var _modals: ModalLayer
var _reports: HistoryReports


## The sheet of [param entries], oldest first as the player keeps them; the
## reports [param reports] has pages for open on [param modals].
func _init(entries_: Array[HistoryEntry], modals: ModalLayer, reports := HistoryReports.new()) -> void:
	entries = entries_
	_modals = modals
	_reports = reports
	super()
	placement = Placement.BOTTOM
	theme_type_variation = &"BottomSheetPanel"
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for side: String in ["left", "right", "top", "bottom"]:
		empty_box.add_theme_constant_override("margin_" + side, EMPTY_PADDING)
	empty_box.add_child(empty_label)
	list.add_theme_constant_override(&"separation", GAP)
	list.add_child(empty_box)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(_padded(list, LIST_PADDING))
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 0)
	column.add_child(handle)
	column.add_child(_padded(chips, CHIPS_PADDING))
	column.add_child(HSeparator.new())
	column.add_child(scroll)
	add_child(column)
	handle.pulled.connect(_pulled)
	chips.changed.connect(show_filter)
	show_filter(HistoryFilter.Value.ALL)


## Shows the entries [param filter] keeps, newest first, or why there are none.
func show_filter(filter: HistoryFilter.Value) -> void:
	for card in cards:
		card.free()
	cards.clear()
	var kept := HistoryFilter.apply(_newest_first(), filter)
	for entry in kept:
		var card := HistoryEntryCard.new(entry)
		card.tapped.connect(_open_report.bind(entry))
		list.add_child(card)
		cards.append(card)
	empty_box.visible = kept.is_empty()
	refresh()


func refresh() -> void:
	empty_label.text = Texts.t(&"historyEmpty" if entries.is_empty() else &"historyEmptyFilter")


func fit(area: Vector2) -> void:
	custom_minimum_size = Vector2(area.x, area.y * HEIGHT_SHARE)


func _newest_first() -> Array[HistoryEntry]:
	var reversed := entries.duplicate()
	reversed.reverse()
	return reversed


func _open_report(entry: HistoryEntry) -> void:
	var page := _reports.page_for(entry)
	if page != null:
		_modals.open(page)


func _pulled(distance: float) -> void:
	if dismissible and distance >= BottomSheet.DISMISS_PULL:
		close()


static func _padded(content: Control, padding: Vector2i) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override(&"margin_left", padding.x)
	margin.add_theme_constant_override(&"margin_right", padding.x)
	margin.add_theme_constant_override(&"margin_top", padding.y)
	margin.add_theme_constant_override(&"margin_bottom", padding.y)
	margin.add_child(content)
	return margin
