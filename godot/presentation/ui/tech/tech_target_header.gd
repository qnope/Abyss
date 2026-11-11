class_name TechTargetHeader
extends HBoxContainer
## The top of a target's panel: the icon, the name and the effect of a branch
## or of a node of a tier, and the button that unlocks or researches it
## (lib/presentation/widgets/tech/tech_target_header.dart). A node of choice
## only gets a title and the warning that one option will be lost: its options
## carry their own buttons. [signal act_pressed] tells a press of the button.

## The player pressed "Débloquer" or "Rechercher".
signal act_pressed

const ICON_SIZE := 48.0
const GAP := 12

var target: TechTarget
## The picture of a branch or of a tier; null on a node of choice.
var icon: UiIcon
var title_label := Label.new()
var subtitle_label := Label.new()
## The button; null when the target has none (a choice, a target done).
var act_button: Button


## The header of [param target_]; [param with_button] adds its button, lit
## when [param can_act].
func _init(target_: TechTarget, with_button: bool, can_act: bool) -> void:
	target = target_
	add_theme_constant_override(&"separation", GAP)
	var branch := target.branch
	var color := TechColors.of(branch)
	if not target.is_choice():
		icon = TechIcons.branch_icon(branch, ICON_SIZE, color) if target.is_branch() \
			else UiIcon.new(TechIcons.node_path(branch, target.level), ICON_SIZE)
		add_child(icon)
	title_label.theme_type_variation = &"TitleMedium"
	title_label.add_theme_color_override(&"font_color", color)
	subtitle_label.theme_type_variation = &"BodySmall"
	subtitle_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for each: Label in [title_label, subtitle_label]:
		each.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texts.add_child(each)
	add_child(texts)
	_write_texts()
	if with_button:
		act_button = Button.new()
		act_button.text = Texts.t(&"techScreenUnlock" if target.is_branch() else &"techScreenResearch")
		act_button.disabled = not can_act
		act_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		act_button.pressed.connect(act_pressed.emit)
		add_child(act_button)


func _write_texts() -> void:
	var branch := target.branch
	var branch_name := TechBranchTexts.display_name(branch)
	var level := target.level
	if target.is_branch():
		title_label.text = branch_name
		subtitle_label.text = TechBranchTexts.description(branch)
	elif target.is_choice():
		title_label.text = Texts.t(&"techScreenChoiceTitle", {"branch": branch_name, "level": level})
		subtitle_label.text = Texts.t(&"techScreenChoiceWarning")
	else:
		title_label.text = TechNodeTexts.node_name(branch, level)
		subtitle_label.text = Texts.t(&"techScreenNodeSubtitle", {
			"branch": branch_name, "level": level, "effect": TechNodeTexts.node_effect(branch, level)})
