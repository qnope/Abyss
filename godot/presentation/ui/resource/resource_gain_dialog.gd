class_name ResourceGainDialog
extends AbyssDialog
## What was found: a line per resource gained, its icon, its name and "+N" in
## its colour, or that there was nothing, and an OK
## (lib/presentation/widgets/resource/resource_gain_dialog.dart). Resources
## go in the order of the game, not of the map.

const ICON_SIZE := 24.0
const LINE_GAP := 8

var gains: Dictionary[ResourceType.Value, int] = {}
var name_labels: Dictionary[ResourceType.Value, Label] = {}
## What it says when nothing was found: the caller's, else "Rien à récupérer
## ici...".
var empty_message := ""
var _empty_label := Label.new()
var _ok: Button


func _init(title_text: String, deltas: Dictionary[ResourceType.Value, int], empty := "") -> void:
	empty_message = empty
	super(title_text)
	for type: ResourceType.Value in ResourceType.Value.values():
		if deltas.get(type, 0) > 0:
			gains[type] = deltas[type]
			body.add_child(_line(type))
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_label.visible = gains.is_empty()
	body.add_child(_empty_label)
	_ok = add_action("", null, &"")
	refresh()


func refresh() -> void:
	# Called once by the base class, before the lines are built.
	for type: ResourceType.Value in name_labels:
		name_labels[type].text = ResourceTexts.display_name(type)
	_empty_label.text = empty_message if not empty_message.is_empty() else Texts.t(&"screenNothingToCollect")
	if _ok != null:
		_ok.text = Texts.t(&"commonOk")


func _line(type: ResourceType.Value) -> Control:
	var line := HBoxContainer.new()
	line.add_theme_constant_override(&"separation", LINE_GAP)
	var name_label := Label.new()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_labels[type] = name_label
	var amount := Label.new()
	amount.text = "+%d" % gains[type]
	amount.add_theme_color_override(&"font_color", ResourceColors.of(type))
	line.add_child(ResourceIcon.new(type, ICON_SIZE))
	line.add_child(name_label)
	line.add_child(amount)
	return line
