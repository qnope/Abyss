class_name GameOverScreens
extends RefCounted
## The end-of-game screens of a game, with what they show read from it
## (lib/presentation/screens/game/game_screen_defeat_actions.dart:
## defeatRoute; game_screen_victory_actions.dart: showVictoryScreen). They
## are built here and not by static functions of the screens: a node class
## that builds itself in a static function leaks its script when it extends
## another script of the project (Godot 4.7).


## The defeat screen of a lost [param game]: the faction that won, if one did,
## else why the raids won.
static func defeat(game: Game) -> DefeatScreen:
	var winner := VictoryChecker.winner_of(game)
	var faction: Variant = null
	if winner != null and winner.id != game.human_player_id:
		faction = winner.name
	var statistics := GameStatisticsCalculator.new().compute(game)
	return DefeatScreen.new(statistics, game.turn - 1, faction, DefeatAnalysis.of(game) if faction == null else null)


## The victory screen of a won [param game].
static func victory(game: Game) -> VictoryScreen:
	return VictoryScreen.new(GameStatisticsCalculator.new().compute(game))
