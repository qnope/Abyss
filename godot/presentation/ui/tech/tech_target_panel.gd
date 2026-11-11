class_name TechTargetPanel
extends PanelContainer
## What a touch on a branch or a node of the tree opens: the target, its
## effect, its cost or what blocks it, and the button to unlock or research it;
## a node of choice shows its two options face to face
## (lib/presentation/widgets/tech/tech_target_panel.dart). It is built from a
## [TechView] and tells [signal act_pressed] with the option taken (A on a node
## without choice); the sheet that holds it runs the action and builds it
## again.

## The player asked to unlock the branch or to research the node, taking
## [param option] on a node of choice.
signal act_pressed(option: TechOption.Value)

const RADIUS := 16
const PADDING := Vector2i(16, 12)
const GAP := 8

var view: TechView
var target: TechTarget
var header: TechTargetHeader
## The two options of a node of choice, null on the others.
var choice_row: TechChoiceRow
## "Acquis ✓", or what blocks the target; null while it can be paid for.
var status_label: Label
## What the target costs; null when it is done or blocked.
var cost_row: TechCostRow
## What opening a branch adds to every cost, null but on a branch to unlock
## while another is open.
var surcharge_label: Label


func _init(view_: TechView, target_: TechTarget) -> void:
	view = view_
	target = target_
	var done := view.is_done(target)
	var can_act := view.can_act(target)
	var color := TechColors.of(target.branch)
	var box := AbyssBox.flat(AbyssColors.SURFACE_LIGHT, RADIUS, PADDING)
	add_theme_stylebox_override(&"panel", AbyssBox.rimmed(box, Color(color, 0.4)))
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	header = TechTargetHeader.new(target, not target.is_choice() and not done, can_act)
	header.act_pressed.connect(act_pressed.emit.bind(TechOption.Value.A))
	column.add_child(header)
	if target.is_choice():
		var state := view.state_of(target.branch)
		var taken: Variant = state.option_at(target.level) if state != null else null
		choice_row = TechChoiceRow.new(target.branch, target.level, taken, can_act)
		choice_row.chosen.connect(act_pressed.emit)
		column.add_child(choice_row)
	_add_status(column, done)
	add_child(column)


func _add_status(column: VBoxContainer, done: bool) -> void:
	var reason := view.blocker(target)
	if done or not reason.is_empty():
		status_label = Label.new()
		status_label.theme_type_variation = &"LabelLarge"
		status_label.text = Texts.t(&"techScreenAcquired") if done else reason
		status_label.add_theme_color_override(&"font_color", AbyssColors.SUCCESS if done else AbyssColors.WARNING)
		column.add_child(status_label)
		return
	cost_row = TechCostRow.new(view.costs(target), view.resources)
	column.add_child(cost_row)
	if target.is_branch() and view.opened > 0:
		surcharge_label = Label.new()
		surcharge_label.theme_type_variation = &"BodySmall"
		surcharge_label.text = Texts.t(&"techScreenSurcharge", {
			"factor": LocalizedDecimal.format(view.surcharge_factor(), TranslationServer.get_locale())})
		surcharge_label.add_theme_color_override(&"font_color", AbyssColors.WARNING)
		surcharge_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		column.add_child(surcharge_label)
