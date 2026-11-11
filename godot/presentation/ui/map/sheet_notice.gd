class_name SheetNotice
extends HBoxContainer
## A short timed notice of a map sheet, under its title (lib/presentation/
## widgets/map/sheet_notice.dart): an hourglass and a text in the warning colour,
## such as "Épave : encore 3 tours". The text is written by a function, so that
## the notice follows the language by itself.

const GAP := 6
const ICON_SIZE := 18.0

var label := Label.new()
var _source: Callable


## A notice saying what [param source] (a function with no argument returning
## a String) writes.
func _init(source: Callable) -> void:
	_source = source
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override(&"separation", GAP)
	label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
	add_child(UiIcon.glyph(&"timer", ICON_SIZE, AbyssColors.WARNING))
	add_child(label)
	refresh()


## Writes the text again.
func refresh() -> void:
	label.text = _source.call()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _source.is_valid():
		refresh()
