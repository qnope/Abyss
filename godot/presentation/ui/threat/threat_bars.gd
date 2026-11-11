class_name ThreatBars
extends RefCounted
## The threats' strips of the game screen, in the order Flutter stacks them
## under the resource bar (lib/presentation/widgets/common/
## game_status_bars.dart): the noise gauge or the raid alert, the guardians
## coming back to the Faille, the kraken wave. Each redraws with the game and
## hides itself when it has nothing to tell.


## Stacks the threat strips of [param game] on [param bars]. The strip of the
## guardians is touched to open the Faille they strike: [param open_map] (taking
## the level) is called then; without one the strip is only read.
static func add_to(bars: GameStatusBars, game: Game, open_map := Callable()) -> void:
	bars.add_bar(RaidStatusBar.new(game))
	var guardians := LeviathanStatusBar.new(game, open_map.is_valid())
	if open_map.is_valid():
		guardians.opened.connect(func(announcement: LeviathanAnnouncement) -> void:
			open_map.call(announcement.level))
	bars.add_bar(guardians)
	bars.add_bar(VolcanoStatusBar.new(game))
