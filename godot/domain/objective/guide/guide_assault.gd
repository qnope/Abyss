class_name GuideAssault
extends RefCounted
## lib/domain/objective/guide/guide_assault.dart: what the guide says
## towards the capture of a Faille, a Cheminée or the kernel: an Abyss
## Admiral first, brought down to the level of the assault, then the target
## and the army AssaultPlan advises.

## `levelOf`, a switch on the target in Dart.
const _LEVELS: Dictionary[AssaultTarget.Value, int] = {
	AssaultTarget.Value.FAILLE: 1,
	AssaultTarget.Value.CHEMINEE: 2,
	AssaultTarget.Value.KERNEL: 3,
}
## `_targetOf` of a post, a switch on its type in Dart.
const _TARGETS: Dictionary[TransitionBaseType.Value, AssaultTarget.Value] = {
	TransitionBaseType.Value.FAILLE: AssaultTarget.Value.FAILLE,
	TransitionBaseType.Value.CHEMINEE: AssaultTarget.Value.CHEMINEE,
}


## The advice for `player` towards the capture of `target`.
static func of(game: Game, player: Player, target: AssaultTarget.Value) -> GuideAdvice:
	var level := level_of(target)
	var admiral_level: Variant = _deepest_admiral(player, level)
	if admiral_level == null:
		return _recruit(player, target)
	var from: int = admiral_level
	if from < level:
		var post := GuideMap.held_post_on(game, player, from)
		return GuideAdvice.new(
			GuideAdmiralToSend.new(target, level, from), post if post != null else GuideTarget.for_map()
		)
	var cell := GuideMap.nearest(game, player, target, level)
	if cell == null:
		return GuideAdvice.new(GuidePostToFind.new(target), GuideTarget.for_map())
	return GuideAdvice.new(GuidePostAssault.new(target, _advised(player, target, level)), cell)


## Level of the map `target` stands on.
static func level_of(target: AssaultTarget.Value) -> int:
	return _LEVELS[target]


## Whether an assault on `target` was won this turn of `game` while every
## admiral fell.
static func admiral_fell(game: Game, player: Player, target: AssaultTarget.Value) -> bool:
	for i: int in range(player.history_entries.size() - 1, -1, -1):
		var entry := player.history_entries[i]
		if entry.turn < game.turn:
			return false
		if entry is CaptureEntry:
			var capture: CaptureEntry = entry
			if capture.turn == game.turn and not capture.captured and _target_of(capture) == target:
				return true
	return false


## The barracks the admiral needs, then the admiral.
static func _recruit(player: Player, target: AssaultTarget.Value) -> GuideAdvice:
	var needed := UnitCostCalculator.new().unlock_level(UnitType.Value.ABYSS_ADMIRAL)
	if Building.level_in(player.buildings, BuildingType.Value.BARRACKS) < needed:
		return GuideAdvice.new(
			GuideAdmiralNeedsBarracks.new(target, needed), GuideTarget.for_building(BuildingType.Value.BARRACKS)
		)
	return GuideAdvice.new(GuideAdmiralToRecruit.new(target), GuideTarget.for_unit(UnitType.Value.ABYSS_ADMIRAL))


## The deepest level from 1 to `level` where `player` has an admiral (an
## int), null for none.
static func _deepest_admiral(player: Player, level: int) -> Variant:
	for l: int in range(level, 0, -1):
		if _count(player, l, UnitType.Value.ABYSS_ADMIRAL) > 0:
			return l
	return null


## Harpoonists to send with the admirals and Guardians of `level` (an int),
## null when out of reach.
static func _advised(player: Player, target: AssaultTarget.Value, level: int) -> Variant:
	var army: Dictionary[UnitType.Value, int] = {
		UnitType.Value.ABYSS_ADMIRAL: _count(player, level, UnitType.Value.ABYSS_ADMIRAL),
		UnitType.Value.GUARDIAN: _count(player, level, UnitType.Value.GUARDIAN),
	}
	return AssaultPlan.of(player, level, target, army).suggested_harpoonists()


static func _count(player: Player, level: int, type: UnitType.Value) -> int:
	var unit: Unit = player.units_on_level(level).get(type)
	return unit.count if unit != null else 0


## The target of `entry` (an AssaultTarget.Value), null for none.
static func _target_of(entry: CaptureEntry) -> Variant:
	if entry.is_volcanic_kernel():
		return AssaultTarget.Value.KERNEL
	var name := TransitionBaseName.parse(entry.transition_base_name)
	return null if name == null else _TARGETS[name.type]
