class_name PostTakeover
extends RefCounted
## lib/domain/action/post_takeover.dart: what a won attack does to a post:
## its passage building is destroyed, the units its owner kept on the level
## below are lost with it, and the attacker holds the post, empty until it
## builds a passage of its own. Without attacker (the guardians coming
## back), the monsters guard it again.


## The building that opens `type`: the Module de descente for a Faille,
## the Capsule pressurisée for a Cheminée.
static func passage_of(type: TransitionBaseType.Value) -> BuildingType.Value:
	if type == TransitionBaseType.Value.FAILLE:
		return BuildingType.Value.DESCENT_MODULE
	return BuildingType.Value.PRESSURE_CAPSULE


## Whether `player` built the passage of `type`: below level 1, nobody can
## go down through the post yet.
static func passage_built(player: Player, type: TransitionBaseType.Value) -> bool:
	return Building.level_in(player.buildings, passage_of(type)) > 0


## Whether units of `player` can go down through a post of `type`: its
## passage built and not degraded.
static func passage_works(player: Player, type: TransitionBaseType.Value) -> bool:
	return passage_built(player, type) and not player.is_degraded(passage_of(type))


## Applies the takeover; returns what the owner lost with the post.
## `attacker` is null for the guardians.
static func apply(post: TransitionBase, attacker: Player, owner: Player) -> PostLoss:
	var passage := passage_built(owner, post.type)
	var building: Building = owner.buildings.get(passage_of(post.type))
	if building != null:
		building.level = 0
	var below := owner.units_on_level(post.target_level())
	var lost: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in below:
		if below[type].count > 0:
			lost[type] = below[type].count
	for unit: Unit in below.values():
		unit.count = 0
	var kept := owner.pending_reinforcements.filter(
		func(o: ReinforcementOrder) -> bool: return o.to_level != post.target_level()
	)
	owner.pending_reinforcements.assign(kept)
	post.captured_by = attacker.id if attacker != null else null
	return PostLoss.new(lost, passage)
