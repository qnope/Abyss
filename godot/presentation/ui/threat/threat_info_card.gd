class_name ThreatInfoCard
extends FightReportCard
## A card of a threat report with a coloured glyph, a title and, when there is
## one, a line under it: the Citadel rampart of a raid and the kernel at stake
## of a kraken wave (the ListTile cards of lib/presentation/screens/game/raid/
## raid_summary_screen.dart and volcano/volcano_summary_screen.dart). Both
## texts are [Callable]s called again whenever the language changes.

const ICON_SIZE := 24.0
const GAP := 16

var title_label := text_label(&"BodyLarge")
var subtitle_label := text_label(&"BodyMedium", AbyssColors.ON_SURFACE_DIM)
var _title: Callable
var _subtitle: Callable


## A card with the glyph [param glyph] in [param color], saying what
## [param title] returns and, under it, what [param subtitle] returns (a
## String), or nothing when [param subtitle] is not valid.
func _init(glyph: StringName, color: Color, title: Callable, subtitle := Callable()) -> void:
	_title = title
	_subtitle = subtitle
	super()
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_child(title_label)
	lines.add_child(subtitle_label)
	row.add_child(UiIcon.glyph(glyph, ICON_SIZE, color))
	row.add_child(lines)
	column.add_child(row)
	subtitle_label.visible = subtitle.is_valid()
	refresh()


func refresh() -> void:
	title_label.text = str(_title.call())
	if _subtitle.is_valid():
		subtitle_label.text = str(_subtitle.call())
