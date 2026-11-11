class_name ThreatBars
extends RefCounted
## The threats' strips of the game screen, in the order Flutter stacks them
## under the resource bar (lib/presentation/widgets/common/
## game_status_bars.dart): the noise gauge or the raid alert, the guardians
## coming back to the Faille, the kraken wave. Each redraws with the game and
## hides itself when it has nothing to tell.


## Stacks the threat strips of [param game] on [param bars].
static func add_to(bars: GameStatusBars, game: Game) -> void:
	bars.add_bar(RaidStatusBar.new(game))
	bars.add_bar(LeviathanStatusBar.new(game))
	bars.add_bar(VolcanoStatusBar.new(game))
