class_name ThreatPages
extends RefCounted
## The steps of [TurnOutcome] that show the reports of the threats, after the
## summary and in Flutter's order (lib/presentation/screens/game/
## game_screen_turn_flow.dart: showTurnOutcome): the raid, the school of
## predators, and the kraken wave when it was lost (a wave repelled stays a
## line of the summary). Each takes the game and the turn's result and returns
## the page, or null when the turn has nothing for it.


## The report of the raid fought on the base at the end of the turn.
static func raid(_game: Game, result: TurnResult) -> ModalPanel:
	return null if result.raid == null else RaidReportPage.new(result.raid)


## The report of the school of predators fought at the end of the turn.
static func predators(_game: Game, result: TurnResult) -> ModalPanel:
	return null if result.predators == null else RaidReportPage.new(result.predators)


## The report of a kraken wave that took a level of the kernel.
static func volcano(_game: Game, result: TurnResult) -> ModalPanel:
	var wave := result.volcano
	return null if wave == null or wave.victory else VolcanoReportPage.new(wave)
