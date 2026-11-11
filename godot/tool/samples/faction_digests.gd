class_name FactionDigests
extends RefCounted
## What the digest test of the factions (faction_digest_test.gd) does
## between the turns of the games of GameFactory, as the scratch Dart script
## did, and the short texts it compares with what that script printed: the
## development of ScriptDigests, more armies for the factions, and their
## wars.


## An ActionExecutor that writes down every action it executes, as a
## ScriptLogEntry would.
class Spy:
	extends ActionExecutor

	var seen := PackedStringArray()

	func execute(action: Action, game: Game, player: Player) -> ActionResult:
		var result := super(action, game, player)
		seen.append(str(ScriptLogEntry.new(game.turn, action.description(), result.is_success, result.reason)))
		return result


## More than the scripts' development: a faction sees every base at 3 and
## gets an army at `6 + i`.
static func arm(game: Game, p: Player, t: int, i: int) -> void:
	if p.id == game.human_player_id:
		return
	if t == 3:
		for o: Player in game.players.values():
			if o.id != p.id:
				p.add_revealed_cell(1, GridPosition.new(o.base_x, o.base_y))
	if t == 6 + i:
		p.units_on_level(1)[UnitType.Value.HARPOONIST].count += 30
		p.units_on_level(1)[UnitType.Value.GUARDIAN].count += 10


## `k<kernel level>[H when held]|p<levels of the posts held>|i<intel>|
## pa<post attacks>|ka<kernel attacks>|<assaults>|h<history size>|[F]`.
static func war(game: Game, p: Player) -> String:
	var posts := ""
	for l: int in game.levels:
		for c: MapCell in game.levels[l].cells:
			if c.transition_base != null and c.transition_base.captured_by == p.id:
				posts += str(l)
	var intel := PackedStringArray()
	for id: String in p.intel():
		intel.append("%s@%d" % [id, p.intel()[id].turn])
	var assaults := PackedStringArray()
	for e: BaseAssaultEntry in War.assaults(p):
		var post: String = e.post_name if e.post_name != null else ""
		assaults.append("%d%s%s%s" % [e.turn, "d" if e.defending else "a", "v" if e.victory else "l", post])
	return "k%d%s|p%s|i%s|pa%s|ka%s|%s|h%d|%s" % [
		KernelGarrison.kernel_level_of(p), "H" if game.is_volcanic_kernel_captured_by(p.id) else "",
		posts, ",".join(intel), _turns(p.raid_state.post_attack_turns),
		_turns(p.raid_state.kernel_attack_turns), ",".join(assaults), p.history_entries.size(),
		"F" if p.has_fallen() else "",
	]


static func _turns(by_id: Dictionary[String, int]) -> String:
	var parts := PackedStringArray()
	for id: String in by_id:
		parts.append("%s:%d" % [id, by_id[id]])
	return ",".join(parts)


## Plays `turns` turns of `game` (map seed `seed_`): every player developed,
## then each standing faction's brain with the dice `Random(seed * 100 +
## t * 10 + f)`; then one turn of FactionTurns.play_all. The lines the Dart
## script printed.
static func play(game: Game, seed_: int, turns: int) -> PackedStringArray:
	var lines := PackedStringArray()
	for t: int in range(1, turns + 1):
		game.turn = t
		var i := 0
		for p: Player in game.players.values():
			ScriptDigests.develop(game, p, t, i)
			arm(game, p, t, i)
			i += 1
		var factions := game.factions()
		for f: int in factions.size():
			var p: Player = game.players[factions[f].id()]
			if p.has_fallen():
				continue
			var spy := Spy.new()
			var seeds := DartRandom.new(seed_ * 100 + t * 10 + f, false)
			FactionBrain.new(factions[f].personality).play_turn(FactionTurn.new(game, p, spy, seeds))
			lines.append("%d %s %s = %s # %s next %d" % [
				t, p.id, ", ".join(spy.seen), ScriptDigests.state(game, p), war(game, p), seeds.next_int(1000)
			])
		game.human_player().raid_state.attacks.clear()
		ExplorationResolver.resolve(game)
	game.turn = turns + 1
	var all := Spy.new()
	FactionTurns.play_all(game, all)
	lines.append("all " + ", ".join(all.seen))
	for faction: Faction in game.factions():
		var p: Player = game.players[faction.id()]
		lines.append("end %s = %s # %s" % [p.id, ScriptDigests.state(game, p), war(game, p)])
	return lines
