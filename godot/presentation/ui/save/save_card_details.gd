class_name SaveCardDetails
extends RefreshingPanel
## The text of a save card
## (lib/presentation/widgets/save/save_card_details.dart): name and badge,
## last played date, turn and depth, then the resources of a game in progress
## or how it ended. Everything follows the language.

## Room kept free at the end of the lower lines, under the options.
const TRAILING_GAP := 28
const GAP := 4

var summary: SaveSummary
var name_label := Label.new()
var pill: StatusPill
var date_label := Label.new()
var meta_label := Label.new()
var footnote_label := Label.new()
var strip: ResourceAmountStrip
var _now: int


## [param now] is the time (milliseconds since 1970 UTC) the last played date
## is told against; [param faded] mutes every colour, for a lost game.
func _init(summary_: SaveSummary, now: int, faded := false) -> void:
	super()
	_now = now
	summary = summary_
	var dim := AbyssColors.ON_SURFACE_DIM
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", GAP)
	var head := HBoxContainer.new()
	head.add_theme_constant_override(&"separation", 8)
	name_label.text = summary.player_name
	name_label.theme_type_variation = &"HeadlineLarge"
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_color_override(&"font_color", dim if faded else AbyssColors.BIOLUM_CYAN)
	pill = StatusPill.new("", SaveSummaryTexts.badge_color(summary), faded)
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	date_label.theme_type_variation = &"BodySmall"
	date_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	head.add_child(name_label)
	head.add_child(pill)
	head.add_child(date_label)
	var lower := VBoxContainer.new()
	lower.add_theme_constant_override(&"separation", GAP)
	var gap := MarginContainer.new()
	gap.add_theme_constant_override(&"margin_right", TRAILING_GAP)
	meta_label.theme_type_variation = &"BodyMedium"
	meta_label.add_theme_color_override(&"font_color", dim if faded else AbyssColors.ON_SURFACE)
	meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footnote_label.theme_type_variation = &"BodySmall"
	footnote_label.add_theme_color_override(&"font_color", AbyssColors.dimmed(dim) if faded else dim)
	footnote_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strip = ResourceAmountStrip.new(summary.resources)
	lower.add_child(meta_label)
	lower.add_child(footnote_label)
	lower.add_child(strip)
	gap.add_child(lower)
	column.add_child(head)
	column.add_child(gap)
	add_child(column)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is anything to write.
	if summary == null:
		return
	var footnote: Variant = SaveSummaryTexts.footnote(summary)
	pill.label.text = SaveSummaryTexts.badge_label(summary)
	date_label.text = RelativeDate.relative_to(summary.last_played_at, _now)
	meta_label.text = SaveSummaryTexts.meta_line(summary)
	footnote_label.visible = footnote != null
	footnote_label.text = footnote if footnote != null else ""
	strip.visible = footnote == null
