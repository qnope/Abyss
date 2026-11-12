class_name StrikeSamples
extends RefCounted
## What the tests of the strike and the siege play: a fight of a few turns, an
## army, a lair.


## A fight with a turn for each of [param dealt] (what the player dealt) and the
## [param taken] (what the monsters dealt), won by the player.
static func fight(dealt: Array[int], taken: Array[int]) -> FightResult:
	var turns: Array[FightTurnSummary] = []
	for index in dealt.size():
		turns.append(FightTurnSummary.new(index + 1, 4, 0, dealt[index], taken[index], 3, 2, 30, 20))
	return FightResult.new(CombatSide.Value.PLAYER, dealt.size(), turns, [], [], 5, 0)


## An army of [param count] units of [param type].
static func sent(type := UnitType.Value.HARPOONIST, count := 3) -> Dictionary[UnitType.Value, int]:
	var army: Dictionary[UnitType.Value, int] = {}
	army[type] = count
	return army


## A lair of [param family] (null for the generic monsters).
static func lair(family: Variant = null, difficulty := MonsterDifficulty.Value.MEDIUM) -> MonsterLair:
	return MonsterLair.new(difficulty, 4, family)


## A strike of the army [param army] against [param target], two rounds, won or lost.
static func strike(
	target := Vector2i(3, 3), victory := true, lair_: MonsterLair = null, span := 1,
	army := sent(),
) -> MapStrike:
	var rounds: Array[Vector2i] = [Vector2i(7, 2), Vector2i(4, 0)]
	return MapStrike.new(target, army, rounds, victory, lair_, span)
