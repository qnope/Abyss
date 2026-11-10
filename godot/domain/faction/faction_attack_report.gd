class_name FactionAttackReport
extends RefCounted
## lib/domain/faction/faction_attack_report.dart: an attack of a player on
## the human, reported at the end of a turn: who attacked and the human's
## own report of the fight. Its two enums are AttackTarget and
## AttackOutcome.

var attacker_id: String
var attacker_name: String
## The attacker's FactionPersonality.Value, or null when the attacker is not
## one of the game's factions.
var personality: Variant
## The report of the defender, readable on the assault screen.
var entry: BaseAssaultEntry


func _init(attacker_id_: String, attacker_name_: String, personality_: Variant, entry_: BaseAssaultEntry) -> void:
	attacker_id = attacker_id_
	attacker_name = attacker_name_
	personality = personality_
	entry = entry_


## `FactionAttackReport.of`: the report of `attacker`'s attack in the
## human's `entry_`.
static func of(game: Game, attacker: Player, entry_: BaseAssaultEntry) -> FactionAttackReport:
	var personality_: Variant = null
	for f: Faction in game.factions():
		if f.id() == attacker.id:
			personality_ = f.personality
			break
	return FactionAttackReport.new(attacker.id, attacker.name, personality_, entry_)


func target() -> AttackTarget.Value:
	if entry.post_name == null:
		return AttackTarget.Value.BASE
	if entry.post_name == AttackHeldKernelAction.KERNEL_CODE:
		return AttackTarget.Value.KERNEL
	return AttackTarget.Value.POST


func outcome() -> AttackOutcome.Value:
	if not entry.victory:
		return AttackOutcome.Value.REPELLED
	match target():
		AttackTarget.Value.POST:
			return AttackOutcome.Value.POST_TAKEN
		AttackTarget.Value.KERNEL:
			if entry.rampart_after == 0:
				return AttackOutcome.Value.KERNEL_TAKEN
			return AttackOutcome.Value.KERNEL_DAMAGED
	# AttackTarget.Value.BASE
	for n: int in entry.pillaged.values():
		if n > 0:
			return AttackOutcome.Value.PILLAGED
	return AttackOutcome.Value.DAMAGED


## The post attacked; null for the base, the kernel or a post whose name no
## map generates.
func post() -> TransitionBaseName:
	if target() != AttackTarget.Value.POST:
		return null
	var code: String = entry.post_name
	return TransitionBaseName.parse(code)


## The passage building destroyed with the post taken, if it stood (a
## BuildingType.Value), or null.
func passage_lost() -> Variant:
	var taken := post()
	if taken == null or not entry.victory or not entry.passage_destroyed:
		return null
	return PostTakeover.passage_of(taken.type)


## The level whose units are lost with the post, if it is one (an int), or
## null.
func level_below() -> Variant:
	var taken := post()
	return null if taken == null else taken.target_level()


## How many units the human lost with the post or the kernel taken: those
## killed defending it and those lost with it; the defenders killed when
## the kernel only lost a level; 0 when it held.
func units_lost() -> int:
	match outcome():
		AttackOutcome.Value.POST_TAKEN, AttackOutcome.Value.KERNEL_TAKEN:
			return _sum(entry.dead) + _sum(entry.lost_with_post)
		AttackOutcome.Value.KERNEL_DAMAGED:
			return _sum(entry.dead)
	# _
	return 0


static func _sum(units: Dictionary[UnitType.Value, int]) -> int:
	var total := 0
	for n: int in units.values():
		total += n
	return total
