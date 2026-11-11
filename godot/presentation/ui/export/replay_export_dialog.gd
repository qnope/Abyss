class_name ReplayExportDialog
extends AbyssDialog
## Offers the game as a replay (lib/presentation/widgets/common/
## replay_export_dialog.dart): a JSON scenario that `bin/simulate.dart` plays
## again. It describes the file (its name, how many actions over how many
## turns, and whether the dice were all recorded), and offers to copy it as
## text and, on the web, to download it. A game older than the journal cannot
## be exported and says so.
##
## "Copy" puts the scenario on the clipboard and says so in the dialog, which
## stays open (Flutter closes it and shows a snack bar); "download" hands the
## file to the browser and closes it. Both go through [ReplaySharing].

var game: Game
var sharing: ReplaySharing
## Whether the game kept a journal to export.
var available: bool
var summary_label := Label.new()
## Told after a copy: the scenario is on the clipboard.
var copied_label := Label.new()
var close_button: Button
## Null when the game cannot be exported.
var copy_button: Button
## Null when the game cannot be exported or the platform cannot download.
var share_button: Button


func _init(game_: Game, sharing_ := ReplaySharing.new()) -> void:
	game = game_
	sharing = sharing_
	available = ReplayExport.can_export(game)
	super()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	copied_label.theme_type_variation = &"BodySmall"
	copied_label.add_theme_color_override(&"font_color", AbyssColors.SUCCESS)
	copied_label.visible = false
	body.add_child(summary_label)
	body.add_child(copied_label)
	close_button = add_action("", null)
	if available:
		copy_button = add_button("")
		copy_button.pressed.connect(_copy)
		if sharing.can_download():
			share_button = add_button("", &"")
			share_button.pressed.connect(_download)
	refresh()


func refresh() -> void:
	# Called once by the base class, before the buttons are made.
	if close_button == null:
		return
	set_title(Texts.t(&"screenExportGame"))
	summary_label.text = _summary() if available else Texts.t(&"screenReplayUnavailable")
	copied_label.text = Texts.t(&"screenReplayCopied")
	close_button.text = Texts.t(&"commonClose")
	if copy_button != null:
		copy_button.text = Texts.t(&"screenCopy")
	if share_button != null:
		share_button.text = Texts.t(&"screenShareFile")


func _summary() -> String:
	var actions := 0
	for turn_actions: Array in game.replay.actions.values():
		actions += turn_actions.size()
	var content := Texts.t(&"screenReplaySummary", {
		"file": ReplayExport.file_name(game),
		"actions": Texts.t(&"screenReplayActions", {"count": actions}),
		"turns": Texts.t(&"screenReplayTurns", {"count": game.turn}),
	})
	var exactness := &"screenReplayExact" if ReplayExport.is_exact(game) else &"screenReplayInexact"
	return "%s\n\n%s" % [content, Texts.t(exactness)]


func _copy() -> void:
	sharing.copy(ReplayExport.to_text(game))
	copied_label.visible = true


func _download() -> void:
	sharing.download(ReplayExport.file_name(game), ReplayExport.to_text(game))
	close()
