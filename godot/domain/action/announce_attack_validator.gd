class_name AnnounceAttackValidator
extends RefCounted
## lib/domain/action/announce_attack_validator.dart: the rules that say
## whether a faction may announce an attack on the human for the end of
## turn `arrival_turn`. Each failure is an ActionFailure.Value, or null when
## there is none.


static func check(
	game: Game, player: Player, army: Dictionary[UnitType.Value, int], arrival_turn: int
) -> Variant:
	var human := game.human_player()
	var failure: Variant = AttackBaseValidator.check(game, player, human.id, army)
	if failure != null:
		return failure
	var state := human.raid_state
	if state.has_attack_from(player.id):
		return ActionFailure.Value.ATTACK_ALREADY_ANNOUNCED
	if arrival_turn - _last_attack(human) < Difficulty.attack_gap(game.difficulty()):
		return ActionFailure.Value.ATTACK_TOO_SOON
	# A monster raid already fixed for that turn keeps the human busy.
	if state.is_incoming() and state.arrival_turn == arrival_turn:
		return ActionFailure.Value.RAID_SAME_TURN
	return null


## The turn of the latest attack on the base, announced or fought; minus
## infinity-ish when there was none.
static func _last_attack(human: Player) -> int:
	var last := -1000
	for a: AnnouncedAttack in human.raid_state.attacks:
		if a.arrival_turn > last:
			last = a.arrival_turn
	for e: HistoryEntry in human.history_entries:
		if not e is BaseAssaultEntry:
			continue
		var assault: BaseAssaultEntry = e
		if assault.defending and assault.post_name == null and assault.turn > last:
			last = assault.turn
	return last
