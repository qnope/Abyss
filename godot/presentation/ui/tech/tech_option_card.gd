class_name TechOptionCard
extends PanelContainer
## One of the two options of a choice node: its icon, name and effect, and the
## button that takes it for the rest of the game
## (lib/presentation/widgets/tech/tech_option_card.dart). A taken option says
## so, the one given up is grey and says so too. [signal choose_pressed] tells
## a touch on the button.

## How an option of a choice node stands.
enum Status { OPEN, TAKEN, DISCARDED }

## The player pressed "Choisir".
signal choose_pressed

const RADIUS := 12
const PADDING := Vector2i(10, 10)
const ICON_SIZE := 64.0
const GAP := 6

var status: Status
var icon: UiIcon
var name_label := Label.new()
var effect_label := Label.new()
## "Choisir", on an open option only.
var choose_button: Button
## "Choisi ✓" or "Écarté", on an option that is taken or given up.
var status_label: Label


## The option [param option] of the choice node of [param level] of
## [param branch], standing as [param status_]; [param enabled] lights its
## button.
func _init(branch: TechBranch.Value, level: int, option: TechOption.Value, status_: Status,
		enabled: bool) -> void:
	status = status_
	var color := TechColors.of(branch)
	var rim := color if status == Status.TAKEN else AbyssColors.SURFACE_BRIGHT
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(AbyssBox.flat(AbyssColors.SURFACE_DIM, RADIUS, PADDING), rim))
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon = UiIcon.new(TechIcons.node_path(branch, level, option), ICON_SIZE)
	Greyscale.apply(icon, status == Status.DISCARDED)
	name_label.text = TechNodeTexts.node_name(branch, level, option)
	name_label.theme_type_variation = &"TitleSmall"
	effect_label.text = TechNodeTexts.node_effect(branch, level, option)
	effect_label.theme_type_variation = &"BodySmall"
	effect_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	effect_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	if status == Status.DISCARDED:
		name_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(icon)
	for each: Label in [name_label, effect_label]:
		each.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		each.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(each)
	column.add_child(_footer(enabled))
	add_child(column)


func _footer(enabled: bool) -> Control:
	if status == Status.OPEN:
		choose_button = Button.new()
		choose_button.text = Texts.t(&"techScreenChoose")
		choose_button.disabled = not enabled
		choose_button.pressed.connect(choose_pressed.emit)
		return choose_button
	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.theme_type_variation = &"LabelLarge"
	var taken := status == Status.TAKEN
	status_label.text = Texts.t(&"techScreenChosen" if taken else &"techScreenDiscarded")
	status_label.add_theme_color_override(&"font_color", AbyssColors.SUCCESS if taken else AbyssColors.ON_SURFACE_DIM)
	return status_label
