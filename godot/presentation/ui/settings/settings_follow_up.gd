class_name SettingsFollowUp
extends RefCounted
## What the settings lead to once they end with a way out that opens a page
## (lib/presentation/screens/game/game_screen_settings_actions.dart reads the
## SettingsDialogResult): the page of a result for a game, or null when the
## result opens nothing (cancel, save and quit, a dismissal).
##
## An instance, not a static function of the dialog, so that a lot adds its
## page (the ranking) here and a test hands the HUD another one.


## The page of [param result], not yet opened, null when there is none.
func page(result: Variant, game: Game, modals: ModalLayer) -> ModalPanel:
	if result == SettingsLinks.HISTORY:
		return HistorySheet.new(game.human_player().history_entries, modals)
	if result == SettingsLinks.EXPORT:
		return ReplayExportDialog.new(game)
	return null
