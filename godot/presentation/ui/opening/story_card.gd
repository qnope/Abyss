class_name StoryCard
extends PanelContainer
## A card of a story (lib/presentation/widgets/opening/story_card.dart): the
## picture of its page in a wide frame, its title, its lines told as lore,
## then the footer the pager puts under them, stacked full width.

const PICTURE_HEIGHT := 180.0
const FRAME_RADIUS := 14
const GAP := 10

var title_label := Label.new()
## Under the lines: the dots, the buttons.
var footer := VBoxContainer.new()
var _frame := PanelContainer.new()
var _lines := VBoxContainer.new()


func _init() -> void:
	theme_type_variation = &"DialogPanel"
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var box := AbyssBox.flat(AbyssColors.OCEAN_FLOOR, FRAME_RADIUS)
	_frame.add_theme_stylebox_override(&"panel",
		AbyssBox.rimmed(box, Color(AbyssColors.BIOLUM_CYAN, 0.25)))
	_frame.custom_minimum_size.y = PICTURE_HEIGHT
	title_label.theme_type_variation = &"HeadlineSmall"
	title_label.add_theme_color_override(&"font_color", AbyssColors.BIOLUM_CYAN)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lines.add_theme_constant_override(&"separation", 6)
	column.add_child(_frame)
	column.add_child(title_label)
	column.add_child(_lines)
	column.add_child(footer)
	add_child(column)


## Shows [param page]: its picture, its title and its lines.
func show_page(page: StoryPage) -> void:
	_clear(_frame)
	var picture: Control = page.make_picture.call()
	picture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	picture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_frame.add_child(picture)
	title_label.text = page.title
	_clear(_lines)
	for line in page.lines:
		_lines.add_child(LoreText.new(line, HORIZONTAL_ALIGNMENT_CENTER, LoreText.LARGE))


## The lines now told, top to bottom.
func line_labels() -> Array[Node]:
	return _lines.get_children()


static func _clear(holder: Control) -> void:
	for child in holder.get_children():
		holder.remove_child(child)
		child.free()
