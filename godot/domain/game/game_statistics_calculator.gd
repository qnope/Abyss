class_name GameStatisticsCalculator
extends RefCounted
## lib/domain/game/game_statistics_calculator.dart: the statistics of a
## game, read from the history of a player and the raids of the human.


## The statistics of `player`, the human when null.
func compute(game: Game, player: Player = null) -> GameStatistics:
	var who := player if player != null else game.human_player()
	var monsters_defeated := 0
	var bases_captured := 0
	var collected_resources := 0
	for entry: HistoryEntry in who.history_entries:
		if entry is CombatEntry and (entry as CombatEntry).fight_result.is_victory():
			monsters_defeated += (entry as CombatEntry).fight_result.initial_monster_count
		elif entry is CaptureEntry and (entry as CaptureEntry).captured:
			bases_captured += 1
		elif entry is CollectEntry:
			for amount: int in (entry as CollectEntry).gains.values():
				collected_resources += amount
	var current_resources := 0
	for stock: GameResource in who.resources.values():
		current_resources += stock.amount
	var human := game.human_player()
	return GameStatistics.new(
		# A lost game already moved past the turn the base fell on.
		game.turn - 1 if game.status == GameStatus.Value.DEFEAT else game.turn,
		monsters_defeated,
		bases_captured,
		collected_resources + current_resources,
		human.raid_state.raids_repelled,
		human.raid_state.raids_lost,
	)
