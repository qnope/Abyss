class_name AnnouncedAttackResolver
extends RefCounted
## lib/domain/action/announced_attack_resolver.dart: end-of-turn step that
## fights the attacks announced for the turn that ends, with the units the
## human holds on the base level right now.
##
## It is not an action of the journal: the announcement already is, and the
## fight follows from the state and the announced seed, so a replay that
## never asks a brain fights the very same battles. Each fight is an
## AttackBaseAction, so the rules, the history of both sides, the pillage
## and the damage to the base are those of any attack on a base.


## The record `({AttackBaseResult result, FactionAttackReport report})` of
## an attack fought.
class Fought:
	extends RefCounted
	var result: AttackBaseResult
	var report: FactionAttackReport

	func _init(result_: AttackBaseResult, report_: FactionAttackReport) -> void:
		result = result_
		report = report_


## The results of the attacks fought, in the order they were announced.
static func resolve(game: Game) -> Array[AttackBaseResult]:
	var results: Array[AttackBaseResult] = []
	for f: Fought in fight(game):
		results.append(f.result)
	return results


## The attacks fought, each with its result and the report the human reads,
## in the order they were announced.
static func fight(game: Game) -> Array[Fought]:
	var human := game.human_player()
	var due: Array[AnnouncedAttack] = []
	var kept: Array[AnnouncedAttack] = []
	for a: AnnouncedAttack in human.raid_state.attacks:
		if a.arrival_turn <= game.turn:
			due.append(a)
		else:
			kept.append(a)
	human.raid_state.attacks.assign(kept)
	var fights: Array[Fought] = []
	for a: AnnouncedAttack in due:
		var fought := _fight(game, human, a)
		if fought != null:
			fights.append(fought)
	return fights


static func _fight(game: Game, human: Player, attack: AnnouncedAttack) -> Fought:
	var attacker: Player = game.players.get(attack.attacker_id)
	if attacker == null or attacker.has_fallen():
		return null
	var action := AttackBaseAction.new(human.id, _still_there(attacker, attack.units), DartRandom.new(attack.fight_seed))
	var result := action.execute(game, attacker)
	if not result is AttackBaseResult or not result.is_success:
		return null
	var base_result: AttackBaseResult = result
	attacker.add_history_entry(action.make_history_entry(game, attacker, result, game.turn))
	attacker.raid_state.add_noise(action.noise_made(attacker))
	var entry := AttackBaseEntries.for_defender(game.turn, attacker.name, base_result)
	return Fought.new(base_result, FactionAttackReport.of(game, attacker, entry))


## The announced army, less the units the attacker lost since.
static func _still_there(
	attacker: Player, announced: Dictionary[UnitType.Value, int]
) -> Dictionary[UnitType.Value, int]:
	var units := attacker.units_on_level(RaidBattle.BASE_LEVEL)
	var left: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in announced:
		left[type] = mini(announced[type], units[type].count)
	return left
