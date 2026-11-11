class_name KernelSiege
extends RefCounted
## lib/domain/faction/kernel_siege.dart: the rules of a faction's siege of a
## kernel held high by someone else: from HOT_LEVEL the kernel comes before
## any base or post, and from STEEP_LEVEL the faction settles for a riskier
## win.

## Kernel level from which a held kernel is a target before all others.
const HOT_LEVEL := 7
## Kernel level from which the faction accepts a riskier siege.
const STEEP_LEVEL := 8
## Confidence given up from STEEP_LEVEL: one rehearsal in eight.
const STEEP_DROP := 0.125
## Lowest confidence a siege is ever accepted with: 5 wins out of 8.
const MIN_CONFIDENCE := 0.625
## Off its war slots, a faction tries a hot siege once in so many turns.
const OFF_SLOT_EVERY := 2


## Whether a kernel at `level` is besieged before bases and posts.
static func is_hot(level: int) -> bool:
	return level >= HOT_LEVEL


## Whether `turn` is one where the faction of `personality` tries a hot siege
## off its war slots; the personalities are staggered.
static func is_off_slot(turn: int, personality: FactionPersonality.Value) -> bool:
	return DartMath.modulo(turn + personality, OFF_SLOT_EVERY) == 0


## `planner`, STEEP_DROP less confident against a kernel at `level` of
## STEEP_LEVEL or more, never below MIN_CONFIDENCE.
static func planner_for(planner: ArmyPlanner, level: int) -> ArmyPlanner:
	if level < STEEP_LEVEL:
		return planner
	var eased := maxf(MIN_CONFIDENCE, planner.confidence - STEEP_DROP)
	return ArmyPlanner.new(planner.rehearsals, minf(planner.confidence, eased))


## Sieges a holder may lose a turn: each one costs it a kernel level.
static func won_per_turn(difficulty: Difficulty.Value) -> int:
	return 1 if difficulty == Difficulty.Value.EASY else 2


## Whether `holder` already lost won_per_turn sieges of its kernel on the
## current turn of `game`, read from its history so a replay counts the same.
static func is_capped(game: Game, holder: Player) -> bool:
	var lost := 0
	for e: HistoryEntry in holder.history_entries:
		if _lost(e, game.turn):
			lost += 1
	return lost >= won_per_turn(game.difficulty())


static func _lost(e: HistoryEntry, turn: int) -> bool:
	if not e is BaseAssaultEntry:
		return false
	var assault := e as BaseAssaultEntry
	return (
		assault.turn == turn
		and assault.defending
		and assault.victory
		and assault.post_name == AttackHeldKernelAction.KERNEL_CODE
	)
