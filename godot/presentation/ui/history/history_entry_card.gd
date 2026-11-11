class_name HistoryEntryCard
extends RefreshingPanel
## One entry of the history, as a card tinted with its colour: a glyph (or the
## picture of an event), a title, an optional subtitle and the turn
## (lib/presentation/widgets/history/history_entry_card.dart).
##
## An entry that can be replayed from its stored fight (a combat, a capture, a
## raid, a wave, an assault) is tappable: a chevron on the right, `Tour N` at
## the head of its subtitle, and [signal tapped] when touched. Every other
## entry is a static card with `Tour N` on the right. All the looks come from
## `HistoryEntryDisplay`, the words from `HistoryEntryTexts`; this card holds no
## switch on the kinds of entry.

## The player touched a tappable card.
signal tapped

const RADIUS := 12
const PADDING := Vector2i(16, 10)
const FILL_SHARE := 0.15
const GAP := 16
const GLYPH_SIZE := 24.0
## The side of the picture of an event entry.
const ILLUSTRATION_SIZE := 40.0

var entry: HistoryEntry
var tappable: bool
## The tinted box of the card.
var panel := PanelContainer.new()
var title_label := Label.new()
var subtitle_label := Label.new()
var turn_label := Label.new()
## The touch area over a tappable card, null when it is not.
var tap_button: Button


func _init(entry_: HistoryEntry) -> void:
	entry = entry_
	tappable = HistoryEntryDisplay.is_tappable(entry)
	super()
	var accent := HistoryEntryDisplay.accent_color(entry)
	panel.add_theme_stylebox_override(&"panel", AbyssBox.flat(Color(accent, FILL_SHARE), RADIUS, PADDING))
	title_label.theme_type_variation = &"BodyLarge"
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.theme_type_variation = &"BodySmall"
	subtitle_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	turn_label.theme_type_variation = &"BodySmall"
	turn_label.add_theme_color_override(&"font_color", AbyssColors.ON_SURFACE_DIM)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.add_child(title_label)
	texts.add_child(subtitle_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", GAP)
	row.add_child(_leading(accent))
	row.add_child(texts)
	row.add_child(turn_label)
	if tappable:
		turn_label.visible = false
		row.add_child(UiIcon.glyph(&"chevron_right", GLYPH_SIZE, AbyssColors.ON_SURFACE_DIM))
	panel.add_child(row)
	add_child(panel)
	if tappable:
		tap_button = Button.new()
		tap_button.theme_type_variation = AbyssSurfaceTheme.TAP
		tap_button.pressed.connect(tapped.emit)
		add_child(tap_button)
	refresh()


func refresh() -> void:
	title_label.text = HistoryEntryTexts.title(entry)
	var extra: Variant = HistoryEntryTexts.subtitle(entry)
	var turn := Texts.t(&"commonTurn", {"turn": entry.turn})
	var subtitle := "" if extra == null else str(extra)
	if tappable:
		subtitle = turn if subtitle.is_empty() else "%s · %s" % [turn, subtitle]
	subtitle_label.text = subtitle
	subtitle_label.visible = not subtitle.is_empty()
	turn_label.text = turn
	if tap_button != null:
		tap_button.accessibility_name = title_label.text


## The entry's picture when it has one, else its category's glyph.
func _leading(accent: Color) -> Control:
	var art := HistoryEntryDisplay.illustration(entry)
	if art.is_empty():
		return UiIcon.glyph(HistoryCategoryTexts.icon(entry.category), GLYPH_SIZE, accent)
	return UiIcon.new(art, ILLUSTRATION_SIZE)
