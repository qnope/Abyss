class_name TechNode
extends PanelContainer
## A research node of the tree: a round emblem showing the technology's icon
## (lib/presentation/widgets/tech/tech_node_widget.dart). A researched node
## glows in its branch's colour, the next reachable one is ringed in it, a
## locked one shows its icon faded and grey, and the option a choice left
## aside is grey and struck through. A touch tells [signal tapped]. The
## accessible node's ring is a plain rim where Flutter dashes it.

## The player touched the node.
signal tapped

## The share of the node the icon takes.
const ICON_SHARE := 0.78
const RIM := 2
const STRIKE_INSET := 0.2
const STRIKE_WIDTH := 2.0

var branch: TechBranch.Value
var level: int
## The TechOption of a node of a choice level, null on the others.
var option: Variant
var state: TechNodeState.Value
var icon: UiIcon
## The stroke across a discarded node, null on the others.
var strike: Line2D
var tap_button := Button.new()


## The node of [param level] of [param branch] ([param option] on a choice
## level), standing as [param state_], [param diameter] points across.
func _init(branch_: TechBranch.Value, level_: int, option_: Variant, state_: TechNodeState.Value,
		diameter := 40.0) -> void:
	branch = branch_
	level = level_
	option = option_
	state = state_
	custom_minimum_size = Vector2(diameter, diameter)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_stylebox_override(&"panel", _style(roundi(diameter / 2.0)))
	var lit := state == TechNodeState.Value.RESEARCHED or state == TechNodeState.Value.ACCESSIBLE
	icon = UiIcon.new(TechIcons.node_path(branch, level, option), diameter * ICON_SHARE)
	Greyscale.apply(icon, not lit)
	if state == TechNodeState.Value.LOCKED:
		icon.modulate.a = AbyssColors.UNAVAILABLE_OPACITY
	add_child(icon)
	if state == TechNodeState.Value.DISCARDED:
		strike = _strike(diameter)
		add_child(strike)
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.accessibility_name = TechNodeTexts.node_name(branch, level, option)
	tap_button.pressed.connect(tapped.emit)
	add_child(tap_button)


func _style(radius: int) -> StyleBoxFlat:
	var color := TechColors.of(branch)
	var box := AbyssBox.flat(AbyssColors.SURFACE_DIM, radius)
	match state:
		TechNodeState.Value.RESEARCHED:
			return AbyssBox.glowing(AbyssBox.rimmed(box, color, RIM), Color(color, 0.7), 10)
		TechNodeState.Value.ACCESSIBLE:
			return AbyssBox.glowing(AbyssBox.rimmed(box, Color(color, 0.8), RIM), Color(color, 0.25), 6)
	return AbyssBox.rimmed(box, AbyssColors.SURFACE_BRIGHT, RIM)


## The diagonal across a node the player gave up.
func _strike(diameter: float) -> Line2D:
	var line := Line2D.new()
	var inset := diameter * STRIKE_INSET
	line.points = PackedVector2Array([Vector2(inset, inset), Vector2(diameter - inset, diameter - inset)])
	line.width = STRIKE_WIDTH
	line.default_color = AbyssColors.ON_SURFACE_DIM
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	return line
