class_name FactionIdentity
extends RefreshingPanel
## Who a faction is, centred (lib/presentation/widgets/faction/
## faction_identity.dart): its emblem, its name in its colour, and where it
## comes from in a line of lore.

const EMBLEM_SIZE := 64.0
const GAP := 8

var faction: Faction
var emblem: FactionEmblem
var name_label := Label.new()
var origin_label := LoreText.new("", HORIZONTAL_ALIGNMENT_CENTER)


func _init(faction_: Faction) -> void:
	faction = faction_
	super()
	emblem = FactionEmblem.new(faction.personality, EMBLEM_SIZE)
	name_label.theme_type_variation = &"HeadlineSmall"
	name_label.add_theme_color_override(&"font_color", FactionColors.of(faction.personality))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	column.add_child(emblem)
	column.add_child(name_label)
	column.add_child(origin_label)
	add_child(column)
	refresh()


func refresh() -> void:
	name_label.text = faction.name()
	origin_label.text = FactionPersonalityTexts.origin(faction.personality)
