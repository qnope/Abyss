class_name VictoryChecker
extends RefCounted
## lib/domain/game/victory_checker.dart: the game ends once a kernel stands
## at level 10.

const _WIN_LEVEL := 10


## The new status (a GameStatus.Value) when the game should change, null
## when nothing changes.
static func check(game: Game) -> Variant:
	if game.status == GameStatus.Value.FREE_PLAY:
		return null
	if game.status != GameStatus.Value.PLAYING:
		return null
	var winner := winner_of(game)
	if winner == null:
		return null
	return GameStatus.Value.VICTORY if winner.id == game.human_player_id else GameStatus.Value.DEFEAT


## The player whose kernel stands at level 10, not degraded: the one who
## tamed the volcano, null while nobody has.
static func winner_of(game: Game) -> Player:
	for player: Player in game.players.values():
		var kernel_level := Building.level_in(player.buildings, BuildingType.Value.VOLCANIC_KERNEL)
		if kernel_level >= _WIN_LEVEL and not player.is_degraded(BuildingType.Value.VOLCANIC_KERNEL):
			return player
	return null
