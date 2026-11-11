class_name HeldAttackReports
extends RefCounted
## lib/domain/action/held_attack_reports.dart: the attacks other players
## made this turn on the posts and the kernel the human holds. They are
## fought at once, without warning, while the factions play; the end of the
## turn reports them like the attacks on the base, from the entries they
## left in the human's history, so a replay reports the very same ones.


## The reports of this turn's attacks, in the order they were fought.
static func of(game: Game) -> Array[FactionAttackReport]:
	var human := game.human_player()
	var reports: Array[FactionAttackReport] = []
	for e: HistoryEntry in human.history_entries:
		if not e is BaseAssaultEntry:
			continue
		var assault: BaseAssaultEntry = e
		if assault.turn == game.turn and assault.defending and assault.post_name != null:
			reports.append(_report(game, human, assault))
	return reports


static func _report(game: Game, human: Player, entry: BaseAssaultEntry) -> FactionAttackReport:
	for p: Player in game.players.values():
		if p.id != human.id and p.name == entry.opponent_name:
			return FactionAttackReport.of(game, p, entry)
	return FactionAttackReport.new(entry.opponent_name, entry.opponent_name, null, entry)
