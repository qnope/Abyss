class_name LeviathanDigests
extends RefCounted
## The short texts the digest test of the Leviathan (leviathan_digest_test.gd)
## compares with what a scratch Dart script printed: an announcement, a
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
