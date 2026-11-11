class_name FactionTraits
extends RefCounted
## lib/domain/faction/faction_traits.dart: how a personality plays, as
## numbers the brain reads: how often and how boldly it attacks, what it
## arms with and what it builds first. All of them still run for the kernel;
## a trait only bends the road.
##
## The traits of each personality, private constants in Dart, are built by
## FactionPersonalityTraits, to keep this file short.

const DEFAULT_GROWTH: Array[BuildingType.Value] = [
	BuildingType.Value.HEADQUARTERS,
	BuildingType.Value.SOLAR_PANEL,
	BuildingType.Value.ALGAE_FARM,
	BuildingType.Value.CORAL_MINE,
	BuildingType.Value.ORE_EXTRACTOR,
	BuildingType.Value.BARRACKS,
	BuildingType.Value.LABORATORY,
	BuildingType.Value.CORAL_CITADEL,
]

## Turns between two war slots of the faction.
var cadence: int
## Share of rehearsals the faction must win before it attacks.
var confidence: float
## Every this many slots, the faction goes for the human it has seen and
## can beat, whatever weaker bases it knows.
var grudge_every: int
## What it recruits for war, in this ratio.
var war_mix: Dictionary[UnitType.Value, int]
## Share of the stocks it puts into war_mix each turn.
var war_share: float
## Share of the stocks the conquest of the road to the kernel may spend.
var conquest_share: float
## Whether it recruits to hold the announced raids.
var defends: bool
## Whether it looks at the posts of the others before their bases.
var posts_first: bool
## Turn before which rush_share replaces war_share: an early striker.
var rush_until: int
## Share of the stocks put into war while the rush lasts.
var rush_share: float
## Whether it looks at the kernel others hold before their bases.
var kernel_first: bool
## Share of the home fighters sent down to reinforce the kernel it holds.
var guard_share: float
## Scouts it keeps exploring the level while it is not fully known.
var explorers: int
## The order in which it grows its base.
var growth: Array[BuildingType.Value]


func _init(
	cadence_ := 5,
	confidence_ := 0.85,
	grudge_every_ := 3,
	war_mix_: Dictionary[UnitType.Value, int] = {},
	war_share_ := 0.0,
	conquest_share_ := 0.5,
	defends_ := true,
	posts_first_ := false,
	rush_until_ := 0,
	rush_share_ := 0.0,
	kernel_first_ := false,
	guard_share_ := 0.5,
	explorers_ := 2,
	growth_: Array[BuildingType.Value] = DEFAULT_GROWTH,
) -> void:
	cadence = cadence_
	confidence = confidence_
	grudge_every = grudge_every_
	war_mix = war_mix_
	war_share = war_share_
	conquest_share = conquest_share_
	defends = defends_
	posts_first = posts_first_
	rush_until = rush_until_
	rush_share = rush_share_
	kernel_first = kernel_first_
	guard_share = guard_share_
	explorers = explorers_
	growth = growth_


## Share of the stocks it puts into war on `turn`.
func share_on(turn: int) -> float:
	return rush_share if turn < rush_until else war_share


func planner() -> ArmyPlanner:
	return ArmyPlanner.new(8, confidence)


static func of(personality: FactionPersonality.Value) -> FactionTraits:
	return FactionPersonalityTraits.of(personality)
