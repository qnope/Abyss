class_name FactionStandingTile
extends RefreshingPanel
## One line of the ranking (lib/presentation/widgets/faction/
## faction_standing_tile.dart): the colour of the player, its name, what is
## known of it, where a discovered faction comes from, and a pill when it has
## fallen.

const LEADING_SIZE := 36.0
const GAP := 12
const PADDING := Vector2i(16, 8)

var standing: FactionStanding
var name_label := Label.new()
var depth_label := Label.new()
## The faction's origin, only for a faction the player has seen (else null).
var origin_label: LoreText
## "Fallen", only for a player who has fallen (else null).
var fallen_pill: StatusPill
var leading: Control


func _init(standing_: FactionStanding) -> void:
	standing = standing_
	super()
	var personality: Variant = standing.personality
	if personality == null:
		leading = UiIcon.glyph(&"person", LEADING_SIZE, AbyssColors.BIOLUM_CYAN)
	else:
		var known: FactionPersonality.Value = personality
		leading = FactionEmblem.new(known, LEADING_SIZE)
	name_label.theme_type_variation = &"TitleMedium"
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_color_override(&"font_color", AbyssColors.DISABLED if standing.has_fallen else AbyssColors.ON_SURFACE)
	depth_label.theme_type_variation = &"BodySmall"
	depth_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_child(name_label)
	lines.add_child(depth_label)
	if personality != null and standing.discovered:
		origin_label = LoreText.new("", HORIZONTAL_ALIGNMENT_LEFT, LoreText.SMALL)
		lines.add_child(origin_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(leading)
	row.add_child(lines)
	if standing.has_fallen:
		fallen_pill = StatusPill.new("", AbyssColors.ERROR)
		row.add_child(fallen_pill)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", PADDING.x)
	margin.add_theme_constant_override(&"margin_right", PADDING.x)
	margin.add_theme_constant_override(&"margin_top", PADDING.y)
	margin.add_theme_constant_override(&"margin_bottom", PADDING.y)
	margin.add_child(row)
	add_child(margin)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the labels are placed.
	if leading == null:
		return
	name_label.text = standing.name
	if standing.is_human():
		name_label.text = "%s (%s)" % [standing.name, Texts.t(&"factionRankingYou")]
	var depth := Texts.t(&"factionRankingKernel") if standing.holds_kernel \
		else Texts.t(&"factionRankingDepth", {"level": standing.deepest_level})
	depth_label.text = "%s - %s" % [Texts.t(&"factionRankingHeadquarters", {"level": standing.headquarters_level}), depth]
	if origin_label != null:
		var known: FactionPersonality.Value = standing.personality
		origin_label.text = FactionPersonalityTexts.origin(known)
	if fallen_pill != null:
		fallen_pill.label.text = Texts.t(&"factionRankingFallen").to_upper()
