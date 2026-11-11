class_name GuideSettings
extends RefreshingPanel
## The guide and the tip switches of the human player, each change made
## through the [GameActions] (which saves it with the game right away), and
## the way to the opening story told again
## (lib/presentation/widgets/common/guide_settings.dart). The way to the
## tips already seen, "Revoir les fiches", comes with the tips.

## The player wants the opening story told again.
signal story_requested

var actions: GameActions
var guide_switch := LabeledSwitch.new("", "", false)
var tips_switch := LabeledSwitch.new("", "", false)
var story_row := SettingsRow.new("")


func _init(actions_: GameActions) -> void:
	actions = actions_
	super()
	var column := VBoxContainer.new()
	guide_switch.toggled.connect(actions.set_guide_enabled)
	tips_switch.toggled.connect(actions.set_tips_enabled)
	story_row.pressed.connect(story_requested.emit)
	column.add_child(guide_switch)
	column.add_child(tips_switch)
	column.add_child(story_row)
	add_child(column)
	refresh()


func refresh() -> void:
	var state := ObjectiveMigration.state_of(actions.game, actions.game.human_player())
	_write(guide_switch, &"tutorialGuideSwitch", &"tutorialGuideSwitchHint", state.tutorial_enabled)
	_write(tips_switch, &"tutorialTipsSwitch", &"tutorialTipsSwitchHint", state.tips_enabled)
	story_row.set_title(Texts.t(&"openingStorySettings"))


static func _write(row: LabeledSwitch, title: StringName, hint: StringName, on: bool) -> void:
	row.title_label.text = Texts.t(title)
	row.subtitle_label.text = Texts.t(hint)
	row.switch.accessibility_name = row.title_label.text
	row.set_value(on)
