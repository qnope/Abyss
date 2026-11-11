class_name ObjectivesSheet
extends BottomSheet
## Every objective of the human player, in a bottom sheet
## (lib/.../objectives_sheet.dart): its title, then [ObjectiveSections]. The
## sheet reads the game as it is when it opens and again when the language
## changes. Flutter keeps the title and its divider above the scrolling list;
## here the whole body scrolls under the handle.

const PAD := 16
const GAP := 0

var game: Game
var title_label := Label.new()
var sections := VBoxContainer.new()


func _init(game_: Game) -> void:
	super()
	game = game_
	title_label.theme_type_variation = &"TitleMedium"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sections.add_theme_constant_override(&"separation", GAP)
	var padding := MarginContainer.new()
	for side: String in ["left", "right", "bottom"]:
		padding.add_theme_constant_override("margin_" + side, PAD)
	padding.add_child(sections)
	body.add_child(title_label)
	body.add_child(HSeparator.new())
	body.add_child(padding)
	refresh()


## Lists the objectives again, in the language on.
func refresh() -> void:
	# Called once by the base class, before there is a game to list.
	if game == null:
		return
	title_label.text = Texts.t(&"objectiveSheetTitle")
	for old in sections.get_children():
		sections.remove_child(old)
		old.free()
	for part in ObjectiveSections.of(game):
		sections.add_child(part)

