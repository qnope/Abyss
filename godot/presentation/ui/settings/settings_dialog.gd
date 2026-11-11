class_name SettingsDialog
extends AbyssDialog
## The settings of a game being played: the language, the guide and tip
## switches of the game, and the ways out
## (lib/presentation/widgets/common/settings_dialog.dart). It ends with
## [constant CANCEL], [constant SAVE_AND_QUIT] or one of the [SettingsLinks]
## (the history, the replay export; the ranking comes with its lot), null when
## dismissed.
##
## It saves nothing and navigates nowhere: a language picked is told by
## [signal language_chosen], the switches go through the [GameActions], and
## whoever opened it follows the result.

## Closes the settings and nothing else.
const CANCEL := &"cancel"
## Saves the game and leaves it for the menu.
const SAVE_AND_QUIT := &"saveAndQuit"

## The player picked [param choice] in the picker.
signal language_chosen(choice: LanguageChoice.Value)
## The player wants the opening story told again.
signal story_requested

var picker: LanguagePicker
var guide: GuideSettings
var links := SettingsLinks.new()
var game_label := Label.new()


func _init(actions: GameActions, language: LanguageChoice.Value) -> void:
	super()
	picker = LanguagePicker.new(language)
	picker.language_chosen.connect(language_chosen.emit)
	guide = GuideSettings.new(actions)
	guide.story_requested.connect(story_requested.emit)
	game_label.theme_type_variation = &"LabelLarge"
	game_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	body.add_child(picker)
	body.add_child(HSeparator.new())
	body.add_child(game_label)
	body.add_child(guide)
	body.add_child(HSeparator.new())
	body.add_child(links)
	links.chosen.connect(close)
	add_action("", CANCEL)
	add_action("", SAVE_AND_QUIT, &"")
	refresh()


func refresh() -> void:
	set_title(Texts.t(&"screenSettings"))
	game_label.text = Texts.t(&"screenGameInProgress")
	var buttons := actions()
	if buttons.size() == 2:
		buttons[0].text = Texts.t(&"commonCancel")
		buttons[1].text = Texts.t(&"screenSaveAndQuit")
