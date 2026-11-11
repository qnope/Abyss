class_name DifficultyPicker
extends RefreshingPanel
## One segment per difficulty, with the description of the selected one below
## (lib/presentation/widgets/common/difficulty_picker.dart, whose chips are
## the game's SegmentedBar here). It keeps the difficulty picked, and
## [signal changed] tells each touch on another level.

signal changed(difficulty: Difficulty.Value)

const GAP := 8

var current := Difficulty.Value.NORMAL
var title_label := Label.new()
var description_label := Label.new()
var bar := SegmentedBar.new(_items(), Difficulty.Value.NORMAL)


func _init(current_: Difficulty.Value) -> void:
	super()
	current = current_
	bar.select(current)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	title_label.theme_type_variation = &"TitleMedium"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bar.chosen.connect(_on_chosen)
	description_label.theme_type_variation = &"BodySmall"
	description_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(title_label)
	column.add_child(bar)
	column.add_child(description_label)
	add_child(column)
	refresh()


func refresh() -> void:
	title_label.text = Texts.t(&"difficultyTitle")
	for difficulty: Difficulty.Value in Difficulty.Value.values():
		var name_written := DifficultyTexts.display_name(difficulty)
		bar.name_label(difficulty).text = name_written
		bar.button(difficulty).accessibility_name = name_written
	description_label.text = DifficultyTexts.description(current)


func _on_chosen(difficulty: Difficulty.Value) -> void:
	if difficulty == current:
		return
	current = difficulty
	refresh()
	changed.emit(difficulty)


## A segment per difficulty, written by [method refresh].
static func _items() -> Array[SegmentItem]:
	var items: Array[SegmentItem] = []
	for difficulty: Difficulty.Value in Difficulty.Value.values():
		items.append(SegmentItem.new(difficulty, "", ""))
	return items
