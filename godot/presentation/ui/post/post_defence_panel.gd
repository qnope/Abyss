class_name PostDefencePanel
extends SheetSection
## The defence of a post the player holds (lib/presentation/widgets/map/
## post_defence_panel.dart): the largest faction army its scouts reported, if
## any, then what is lost should the post fall, and a reminder that the
## factions strike without warning.

const EMBLEM_SIZE := 28.0
const GAP_ROW := 10

var post: TransitionBase
var defence: PostDefence
var threat_label: Label
## The things lost with the post, one line each, after a bullet.
var loss_labels: Array[Label] = []


func _init(post_: TransitionBase, defence_: PostDefence) -> void:
	post = post_
	defence = defence_
	super()
	if defence.threat != null:
		column.add_child(_threat_row(defence.threat))
	column.add_child(label(_if_falls, &"TitleSmall", AbyssColors.CORAL_PINK))
	if defence.passage != null:
		var passage: BuildingType.Value = defence.passage
		column.add_child(_loss(func() -> String: return Texts.t(&"postDefencePassageLost",
			{"building": DartEnum.name_of(BuildingType.Value, passage)})))
	if defence.units_below > 0:
		column.add_child(_loss(func() -> String: return Texts.t(&"postDefenceUnitsLost",
			{"count": defence.units_below, "level": post.target_level()})))
	if defence.reinforcements > 0:
		column.add_child(_loss(func() -> String: return Texts.t(&"postDefenceReinforcementsLost",
			{"count": defence.reinforcements})))
	column.add_child(label(func() -> String: return Texts.t(&"postDefenceNoWarning"), &"BodySmall",
		AbyssColors.ON_SURFACE_DIM))


func _if_falls() -> String:
	return Texts.t(&"postDefenceIfFalls", {"kind": DartEnum.name_of(TransitionBaseType.Value, post.type)})


func _threat_row(threat: PostThreat) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP_ROW)
	row.add_child(UiIcon.new(RivalEmblem.path_of(threat.faction.personality), EMBLEM_SIZE))
	threat_label = label(func() -> String: return Texts.t(&"postDefenceThreat",
		{"faction": threat.faction.name(), "units": threat.units, "turn": threat.report_turn}),
		&"", AbyssColors.WARNING)
	threat_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(threat_label)
	return row


## One thing lost with the post, after a bullet.
func _loss(source: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	var bullet := Label.new()
	bullet.text = "•  "
	bullet.add_theme_color_override(&"font_color", AbyssColors.CORAL_PINK)
	var text := label(source)
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loss_labels.append(text)
	row.add_child(bullet)
	row.add_child(text)
	return row
