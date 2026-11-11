class_name LeviathanDigests
extends RefCounted
## The short texts the digest test of the Leviathan (leviathan_digest_test.gd)
## compares with what a scratch Dart script printed: an assault on a post
## nobody holds, an announcement, a
## report of the guardians' attack, the state of their return, and one end
## of turn of the Leviathan step. Each text writes what the Dart script
## writes, in its order, the maps as `name:count`.


static func counts(map: Dictionary) -> String:
	return SiegeDigests.counts(map)


## `post level x,y turn defendingLevel force`, or `-`.
static func announced(a: LeviathanAnnouncement) -> String:
	if a == null:
		return "-"
	var force := PackedStringArray()
	var kinds := a.force()
	for key: String in kinds:
		force.append("%s:%d" % [key, kinds[key]])
	return "%s %d %d,%d %d %d %s" % [a.post_name, a.level, a.at.x, a.at.y, a.turn, a.defending_level(), ",".join(force)]


## `attacker target outcome lost passage below | turn victory turns winner |
## units | intact | wounded | dead | lost passageDestroyed rampart a>b`, or `-`.
static func report(r: FactionAttackReport) -> String:
	if r == null:
		return "-"
	var e := r.entry
	var passage := "null"
	if r.passage_lost() != null:
		var lost: int = r.passage_lost()
		passage = DartEnum.name_of(BuildingType.Value, lost)
	return "%s %s %s %d %s %s | %d %s %d %s | %s | %s | %s | %s | %s %s %d>%d" % [
		r.attacker_id, DartEnum.name_of(AttackTarget.Value, r.target()),
		DartEnum.name_of(AttackOutcome.Value, r.outcome()), r.units_lost(),
		passage,
		WarDigests.text(r.level_below()), e.turn, e.victory, e.fight_result.turn_count,
		DartEnum.name_of(CombatSide.Value, e.fight_result.winner), counts(e.units),
		counts(e.survivors_intact), counts(e.wounded), counts(e.dead), counts(e.lost_with_post),
		e.passage_destroyed, e.rampart_before, e.rampart_after,
	]


## `strikeTurn readyTurn over dueTurn scheduled`.
static func state(s: LeviathanReturn) -> String:
	return "%s %s %s %s %s" % [
		WarDigests.text(s.strike_turn), WarDigests.text(s.ready_turn), s.over,
		WarDigests.text(s.due_turn()), s.is_scheduled(),
	]


## One end of turn, the dice `DartRandom(dice)`: the turn, the attack
## announced for now, the outcome, then the human's level 2, the module, the
## Faille's holder, the state, the history and the reinforcements.
static func step(game: Game, post: TransitionBase, dice: int) -> String:
	var now := announced(LeviathanResolver.announced_now(game))
	var outcome := LeviathanResolver.resolve(game, DartRandom.new(dice))
	var human := game.human_player()
	var line := "%d %s | %s | %s | %s | m%d %s | %s h%d r%d" % [
		game.turn, now, announced(outcome.announced), report(outcome.report),
		counts(human.unit_counts_on_level(2)), human.buildings[BuildingType.Value.DESCENT_MODULE].level,
		WarDigests.text(post.captured_by), state(game.leviathan_return), human.history_entries.size(),
		human.pending_reinforcements.size(),
	]
	game.turn += 1
	return line


## An assault of the human on the first post of `kind` on `level` with
## `army` put there, through ActionExecutor, the dice `DartRandom(dice)`:
## `victory captured turns | sent | intact | wounded | dead` or the
## failure's name, then the units of `level`, the post's holder, the noise,
## the history with its last capture entry, and the state of the return.
static func assault(
	game: Game, kind: TransitionBaseType.Value, level: int, army: Dictionary[UnitType.Value, int], dice: int
) -> String:
	var human := game.human_player()
	var map: GameMap = game.levels[level]
	var at := WarDigests.first(map, func(x: int, y: int) -> bool:
		var base := map.cell_at(x, y).transition_base
		return base != null and base.type == kind)
	WarDigests.put(human, level, army)
	var action := AttackTransitionBaseAction.new(at.x, at.y, level, army, DartRandom.new(dice))
	var r := ActionExecutor.new().execute(action, game, human)
	var entry := "-"
	if not human.history_entries.is_empty() and human.history_entries[-1] is CaptureEntry:
		var last: CaptureEntry = human.history_entries[-1]
		entry = "%d %s %s %d" % [last.turn, last.transition_base_name, last.captured, last.fight_result.turn_count]
	var head := WarDigests.outcome(r)
	if r.is_success:
		var b: AttackTransitionBaseResult = r
		head = "%s %s %d | %s | %s | %s | %s" % [
			b.victory, b.captured, b.fight.turn_count, counts(b.sent), counts(b.survivors_intact),
			counts(b.wounded), counts(b.dead),
		]
	return "assault %s | %s | %s n%d h%d %s | %s" % [
		head, counts(human.unit_counts_on_level(level)), WarDigests.text(map.cell_at(at.x, at.y).transition_base.captured_by),
		human.raid_state.noise, human.history_entries.size(), entry, state(game.leviathan_return),
	]
