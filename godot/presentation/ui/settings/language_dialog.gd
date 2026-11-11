class_name LanguageDialog
extends AbyssDialog
## The settings reachable outside a game: the language picker and a way to
## close it (lib/presentation/widgets/common/language_dialog.dart). It
## follows a language change at once, like the screen below it.

## The player picked [param choice] in the picker.
signal language_chosen(choice: LanguageChoice.Value)

var picker: LanguagePicker


func _init(current: LanguageChoice.Value) -> void:
	super()
	picker = LanguagePicker.new(current)
	picker.language_chosen.connect(language_chosen.emit)
	body.add_child(picker)
	add_action("")
	refresh()


func refresh() -> void:
	set_title(Texts.t(&"screenSettings"))
	for button in actions():
		button.text = Texts.t(&"commonClose")
