class_name VictoryScreen
extends GameOverScreen
## Shown when the Volcanic Kernel stands at the last level
## (lib/presentation/screens/game/victory_screen.dart): the title in gold, the
## statistics, and two ways on: continue in free play, or back to the menu.


## The victory of a game with [param statistics].
func _init(statistics: GameStatistics) -> void:
	var actions: Array[GameOverAction] = [
		GameOverAction.new(GameOverAction.CONTINUE, &"gameOverContinueFreePlay", true),
		GameOverAction.new(GameOverAction.MENU, &"gameOverBackToMenu"),
	]
	super(AbyssColors.WARNING, statistics, null, actions)


func emblem_name() -> String:
	return BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL)


func title_text() -> String:
	return Texts.t(&"gameOverVictoryTitle")


func subtitle_text() -> String:
	return Texts.t(&"gameOverVictorySubtitle")


func lore_text() -> String:
	return Texts.t(&"gameOverVictoryLore")
