class_name SettingsLinks
extends RefreshingPanel
## The ways out of the settings that open a page over the game
## (lib/presentation/widgets/common/settings_dialog.dart: openHistory,
## exportReplay): a row each, Flutter's text buttons. A touch tells which with
## [signal chosen]; the dialog ends with that result and whoever opened it
## shows the page ([SettingsFollowUp]). The ranking is offered to a game that
## has factions.

## Opens the history of the player.
const HISTORY := &"openHistory"
## Opens the ranking of the factions.
const RANKING := &"openRanking"
## Opens the replay export of the game.
const EXPORT := &"exportReplay"

## The player picked the way out [param result].
signal chosen(result: StringName)

var history_row := SettingsRow.new("")
## The ranking, null in a game without factions.
var ranking_row: SettingsRow
var export_row := SettingsRow.new("")


## The links of a game with factions when [param with_ranking].
func _init(with_ranking := false) -> void:
	super()
	var column := VBoxContainer.new()
	history_row.pressed.connect(chosen.emit.bind(HISTORY))
	export_row.pressed.connect(chosen.emit.bind(EXPORT))
	column.add_child(history_row)
	if with_ranking:
		ranking_row = SettingsRow.new("")
		ranking_row.pressed.connect(chosen.emit.bind(RANKING))
		column.add_child(ranking_row)
	column.add_child(export_row)
	add_child(column)
	refresh()


func refresh() -> void:
	history_row.set_title(Texts.t(&"screenViewHistory"))
	if ranking_row != null:
		ranking_row.set_title(Texts.t(&"screenViewRanking"))
	export_row.set_title(Texts.t(&"screenExportGame"))
