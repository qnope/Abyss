class_name GameStatisticsCard
extends RefreshingPanel
## The statistics of a game that ended, shared by the victory and the defeat
## screens (lib/presentation/widgets/game_over/game_statistics_card.dart): a
## card of six lines, each a glyph in cyan and its count.

const ICON_SIZE := 20.0
const GAP := 12
const ROW_PADDING := 4

## The glyph and the text of each line, top to bottom.
const GLYPHS: Array[StringName] = [&"timer", &"dangerous", &"flag", &"inventory", &"shield", &"heart_broken"]
const KEYS: Array[StringName] = [
	&"gameOverTurnsPlayed", &"gameOverMonstersDefeated", &"gameOverBasesCaptured",
	&"gameOverResourcesCollected", &"gameOverRaidsRepelled", &"gameOverRaidsLost",
]

var statistics: GameStatistics
var labels: Array[Label] = []


func _init(statistics_: GameStatistics) -> void:
	statistics = statistics_
	super()
	var card := PanelContainer.new()
	var column := VBoxContainer.new()
	for glyph in GLYPHS:
		var label := Label.new()
		labels.append(label)
		var line := HBoxContainer.new()
		line.add_theme_constant_override(&"separation", GAP)
		line.add_child(UiIcon.glyph(glyph, ICON_SIZE, AbyssColors.BIOLUM_CYAN))
		line.add_child(label)
		var padding := MarginContainer.new()
		padding.add_theme_constant_override(&"margin_top", ROW_PADDING)
		padding.add_theme_constant_override(&"margin_bottom", ROW_PADDING)
		padding.add_child(line)
		column.add_child(padding)
	card.add_child(column)
	add_child(card)
	refresh()


func refresh() -> void:
	var counts: Array[int] = [statistics.turns_played, statistics.monsters_defeated, statistics.bases_captured,
		statistics.total_resources_collected, statistics.raids_repelled, statistics.raids_lost]
	for i in labels.size():
		labels[i].text = Texts.t(KEYS[i], {"count": counts[i]})
