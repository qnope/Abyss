class_name SaveCard
extends RefreshingPanel
## A saved game in the load list (lib/presentation/widgets/save/save_card.dart):
## the depth it reached pictured on the left, its details on the right and its
## options in the corner. A touch anywhere but on the options tells
## [signal tapped]. A lost game is greyed out by its own colours.
##
## Three layers share the card's rectangle: the panel with the content, the
## touch area over it, and the options over that, in the corner.

## The player touched the card: open the game.
signal tapped
## The player chose to delete the game, from the options.
signal delete_requested

const THUMBNAIL_SIZE := 76.0
const GAP := 12

var summary: SaveSummary
## The panel with the content, in the look of the game's state.
var panel := PanelContainer.new()
var tap_button := Button.new()
var menu := SaveCardMenu.new()
var details: SaveCardDetails
var thumbnail: Portrait


## [param highlighted] makes it glow: the game a player most likely resumes.
## [param now] is the time (milliseconds since 1970 UTC) its date is told
## against.
func _init(summary_: SaveSummary, now: int, highlighted := false) -> void:
	super()
	summary = summary_
	var faded := summary.outcome == SaveOutcome.Value.DEFEAT
	panel.theme_type_variation = _variation(highlighted, faded)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var tint := AbyssColors.ON_SURFACE_DIM if faded else AbyssColors.BIOLUM_CYAN
	thumbnail = Portrait.new(SaveSummaryTexts.depth_name(summary), THUMBNAIL_SIZE, tint)
	thumbnail.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if faded:
		thumbnail.modulate.a = AbyssColors.UNAVAILABLE_OPACITY
	details = SaveCardDetails.new(summary, now, faded)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(thumbnail)
	row.add_child(details)
	panel.add_child(row)
	tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
	tap_button.accessibility_name = summary.player_name
	tap_button.pressed.connect(tapped.emit)
	menu.size_flags_horizontal = Control.SIZE_SHRINK_END
	menu.size_flags_vertical = Control.SIZE_SHRINK_END
	menu.delete_requested.connect(delete_requested.emit)
	add_child(panel)
	add_child(tap_button)
	add_child(menu)


func refresh() -> void:
	# Called once by the base class, before there is anything to write.
	if thumbnail == null:
		return
	thumbnail.initials_label.text = Portrait.initials(SaveSummaryTexts.depth_name(summary))


static func _variation(highlighted: bool, faded: bool) -> StringName:
	if faded:
		return &"SavePanelFaded"
	return &"SavePanelHighlighted" if highlighted else &"SavePanel"
