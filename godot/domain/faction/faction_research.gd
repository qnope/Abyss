class_name FactionResearch
extends RefCounted
## lib/domain/faction/faction_research.dart: what a faction researches, by
## personality: the plan of a careful player with the Explorer branch in it,
## deeper and earlier for the personalities that go for the kernel.
##
## Plans use the encoding of GrowthMoves.RESEARCH_PLAN: each entry is the
## next node of its branch.

const Branch := TechBranch.Value
const Option := TechOption.Value
const _P := FactionPersonality.Value

## Explorer opens as the third branch, after Military 3, so that the dearer
## research that follows does not weaken the armies.
const DEFAULT_PLAN: Array[Branch] = [
	Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES,
	Branch.MILITARY, Branch.MILITARY, Branch.EXPLORER,
	Branch.EXPLORER, Branch.RESOURCES, Branch.MILITARY,
	Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES,
]

## Explorer right after Military 2, and down to node 3 after Resources 3:
## the sonar finds the kernel sooner.
const SEEKER_PLAN: Array[Branch] = [
	Branch.RESOURCES, Branch.MILITARY, Branch.RESOURCES,
	Branch.MILITARY, Branch.EXPLORER, Branch.EXPLORER,
	Branch.MILITARY, Branch.RESOURCES, Branch.EXPLORER,
	Branch.MILITARY, Branch.RESOURCES, Branch.MILITARY,
	Branch.RESOURCES,
]

## The personalities turned towards the kernel.
const KERNEL_SEEKERS: Dictionary[_P, bool] = {
	_P.CURRENT_NOMADS: true,
	_P.KRAKEN_FAITHFUL: true,
	_P.MAGMA_SMITHS: true,
}

## Deep Sonar at node 2, Wreck Raiders at node 4.
const DEFAULT_PICKS: Dictionary[Branch, Array] = {
	Branch.MILITARY: [Option.B, Option.A],
	Branch.RESOURCES: [Option.A, Option.A],
	Branch.EXPLORER: [Option.A, Option.A],
}

## Silent Swim at node 2: less noise, so fewer raids.
const SILENT_PICKS: Dictionary[Branch, Array] = {
	Branch.MILITARY: [Option.B, Option.A],
	Branch.RESOURCES: [Option.A, Option.A],
	Branch.EXPLORER: [Option.B, Option.B],
}


## The research plan of `personality`.
static func plan_of(personality: _P) -> Array[Branch]:
	return SEEKER_PLAN if KERNEL_SEEKERS.has(personality) else DEFAULT_PLAN


## The options `personality` takes at the choice nodes 2 and 4.
static func picks_of(personality: _P) -> Dictionary[Branch, Array]:
	return SILENT_PICKS if personality == _P.SILENCE_MONKS else DEFAULT_PICKS
