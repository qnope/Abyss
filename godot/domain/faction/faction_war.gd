class_name FactionWar
extends RefCounted
## lib/domain/faction/faction_war.dart: when and whom a faction attacks. One
## conservative rule that every personality shares until its own war brain
## exists (step 11).
##
## Once in a while, on a slot of its own, a faction looks at the bases its
## fog has shown. If its fighters would beat the defence of the weakest of
## them in at least planner's confidence of its rehearsals, it attacks:
## another faction at once, the human at the end of the turn, without
## warning (FactionBaseWar). It never has two attacks of its own pending.
##
## When no base is worth attacking it looks at the posts of the others
## (FactionPostWar), and at the kernel another holds (FactionKernelWar). A
## kernel held at KernelSiege.HOT_LEVEL or more comes before all of them, and
## is also tried off the slots (KernelSiege.is_off_slot).
##
## Dart's constant `planner` is the function `planner()`, a new object each
## call.

## Units that never leave: they do not fight in a base war.
const _STAY_HOME: Dictionary[UnitType.Value, bool] = {
	UnitType.Value.SCOUT: true,
	UnitType.Value.ABYSS_ADMIRAL: true,
}


## Rehearses the fight before committing: 85 % of 8 rehearsals won.
static func planner() -> ArmyPlanner:
	return ArmyPlanner.new()


## Whether the faction of `personality` may attack on `turn`; the
## personalities are spread over the cadence so they do not all strike at
## once.
static func is_due(turn: int, personality: FactionPersonality.Value) -> bool:
	return DartMath.modulo(turn + personality, FactionTraits.of(personality).cadence) == 0


## Whether `turn` is a slot where the faction of `personality` holds its
## grudge: it goes for the human it can beat before any weaker base. One slot
## in FactionTraits.grudge_every, counted from the turn alone so a replay
## needs no memory of it.
static func is_grudge_slot(turn: int, personality: FactionPersonality.Value) -> bool:
	if not is_due(turn, personality):
		return false
	var traits := FactionTraits.of(personality)
	var slot := DartMath.trunc_div(turn + personality, traits.cadence)
	return DartMath.modulo(slot, traits.grudge_every) == 0


static func play(turn: ScriptTurn, personality: FactionPersonality.Value) -> void:
	var traits := FactionTraits.of(personality)
	var judge := traits.planner()
	if not is_due(turn.number(), personality):
		if KernelSiege.is_off_slot(turn.number(), personality):
			FactionKernelWar.besiege_hot(turn, judge)
		return
	# The hot kernel goes first: a player is hit once a turn by the same
	# faction, and a pending attack on the human base does not hold it.
	var besieged := FactionKernelWar.besiege_hot(turn, judge)
	if turn.game.human_player().raid_state.has_attack_from(turn.player.id):
		return
	FactionSpyScout.keep(turn, personality)
	if besieged:
		return
	var grudge := is_grudge_slot(turn.number(), personality)
	if traits.kernel_first and not grudge and FactionKernelWar.besiege_cold(turn, judge):
		return
	var attacked: bool
	if traits.posts_first and not grudge:
		attacked = FactionPostWar.play(turn, judge) or FactionBaseWar.play(turn, judge, grudge)
	else:
		attacked = FactionBaseWar.play(turn, judge, grudge) or FactionPostWar.play(turn, judge)
	if not attacked and not traits.kernel_first:
		FactionKernelWar.besiege_cold(turn, judge)


## The units of `level` that `me` sends to war.
static func fighters_on(me: Player, level: int) -> Dictionary[UnitType.Value, int]:
	var fighters: Dictionary[UnitType.Value, int] = {}
	var units := me.units_on_level(level)
	for type: UnitType.Value in units:
		if not _STAY_HOME.has(type) and units[type].count > 0:
			fighters[type] = units[type].count
	return fighters
