class_name DefeatScreen
extends GameOverScreen
## Shown when the base fell, to the raids or to a faction that tamed the
## volcano first (lib/presentation/screens/game/defeat_screen.dart): the title
## in red, when and why the base fell, a card with the raids that did it, the
## statistics, and the only way out, the menu. The game is over.
##
## Not here yet: "Exporter la partie" (the replay export, lot 14), which will
## be one more [GameOverAction].

## The turn at the end of which the base fell.
var fall_turn: int
## The name of the faction that tamed the volcano first, null when the base
## fell to the raids.
var winner_name: Variant


## The defeat of a game with [param statistics]. [param analysis] explains a
## fall to the raids; null when a faction won, or no lost raid is left in the
## history.
func _init(statistics: GameStatistics, fall_turn_: int, winner_name_: Variant, analysis: DefeatAnalysis) -> void:
	fall_turn = fall_turn_
	winner_name = winner_name_
	var menu: Array[GameOverAction] = [GameOverAction.new(GameOverAction.MENU, &"gameOverBackToMenu", true)]
	super(AbyssColors.ERROR, statistics, null if analysis == null else DefeatCauseCard.new(analysis), menu)


func emblem_name() -> String:
	return BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS)


func title_text() -> String:
	return Texts.t(&"gameOverDefeatTitle")


func subtitle_text() -> String:
	if winner_name == null:
		return Texts.t(&"gameOverDefeatSubtitle", {"turn": fall_turn, "raids": DefeatChecker.LOST_RAIDS_LIMIT})
	return Texts.t(&"gameOverFactionWonSubtitle", {"name": winner_name, "turn": fall_turn})


func lore_text() -> String:
	return Texts.t(&"gameOverDefeatLore" if winner_name == null else &"gameOverFactionWonLore")
