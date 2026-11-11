class_name LanguagePicker
extends RefreshingPanel
## The "Langue" section of a settings screen: automatic, then each language
## named in itself, the current choice checked
## (lib/presentation/widgets/common/language_picker.dart). A touch on a row
## tells [signal language_chosen] and checks it; it saves nothing, `app/`
## does.

## The player picked [param choice] (even the one already on).
signal language_chosen(choice: LanguageChoice.Value)

var title_label := Label.new()
var _rows: Dictionary[LanguageChoice.Value, LanguageRow] = {}


func _init(current: LanguageChoice.Value) -> void:
	super()
	var column := VBoxContainer.new()
	title_label.theme_type_variation = &"LabelLarge"
	title_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	column.add_child(title_label)
	for choice: LanguageChoice.Value in LanguageChoice.Value.values():
		var row := LanguageRow.new(choice)
		row.pressed.connect(_on_pressed.bind(choice))
		_rows[choice] = row
		column.add_child(row)
	add_child(column)
	select(current)
	refresh()


## The row of [param choice].
func row(choice: LanguageChoice.Value) -> LanguageRow:
	return _rows[choice]


## Checks [param choice] without telling it.
func select(choice: LanguageChoice.Value) -> void:
	for each: LanguageChoice.Value in _rows:
		_rows[each].set_selected(each == choice)


func refresh() -> void:
	title_label.text = Texts.t(&"settingsLanguageTitle")
	for each: LanguageRow in _rows.values():
		each.refresh()


func _on_pressed(choice: LanguageChoice.Value) -> void:
	select(choice)
	language_chosen.emit(choice)
