class_name FactionPostWar
extends RefCounted
## lib/domain/faction/faction_post_war.dart: a faction that takes the Failles
## and Cheminées of the others, the weakest defence first, when its fighters
## of the level beat it in the same share of rehearsals as for a base
## (FactionWar.planner).
##
## It only looks at the posts its own fog has shown. A post is defended by
## the units its owner has below it, so it attacks with the fighters of the
## level the post stands on. The human is not warned: the attack is resolved
## at once, kept in the history and reported at the end of the turn.

## Levels with a post: the Failles on the first, the Cheminées on the second.
const LEVELS: Array[int] = [1, 2]


## A post of another player, with the army of its level (`_Post` in Dart).
class Post:
	var level: int
	var at: GridPosition
	var base: TransitionBase
	var owner: Player
	var army: Dictionary[UnitType.Value, int]
	## How hard the defence hits back at the attacking army.
	var strength: float

	func _init(
		level_: int, at_: GridPosition, base_: TransitionBase, owner_: Player,
		army_: Dictionary[UnitType.Value, int], ours: Array[Combatant],
	) -> void:
		level = level_
		at = at_
		base = base_
		owner = owner_
		army = army_
		strength = ArmyPlanner.strength(BaseDefence.post(owner_, base_.target_level()).side, ours)

	func defence() -> Array[Combatant]:
		return BaseDefence.post(owner, base.target_level()).side


## Attacks the weakest beatable post; returns whether it attacked. `planner`
## null is FactionWar.planner().
static func play(turn: ScriptTurn, planner: ArmyPlanner = null) -> bool:
	var judge := planner if planner != null else FactionWar.planner()
	var boost := FightMonsterHelpers.unit_boost_of(turn.player, true)
	for post: Post in _weakest_first(turn, boost):
		if not judge.wins(post.army, post.defence, boost):
			continue
		if AssaultMoves.attack_post(turn, post.level, post.at.x, post.at.y, post.army):
			return true
	return false


static func _weakest_first(turn: ScriptTurn, boost: UnitBoost) -> Array[Post]:
	var game := turn.game
	var posts: Array[Post] = []
	for level: int in LEVELS:
		var map: GameMap = game.levels.get(level)
		var army := FactionWar.fighters_on(turn.player, level)
		if map == null or army.is_empty():
			continue
		var ours := CombatantBuilder.player_combatants_from(army, boost)
		for key: Vector2i in _seen(turn.player, level):
			var cell := map.cell_at(key.x, key.y)
			var base := cell.transition_base
			var owner: Player = null
			if base != null and base.captured_by != null:
				owner = game.players.get(base.captured_by)
			if (
				base == null
				or cell.content != CellContentType.Value.TRANSITION_BASE
				or owner == null
				or owner.id == turn.player.id
				or owner.has_fallen()
				or AttackCooldown.on_posts(game, turn.player, owner)
			):
				continue
			posts.append(Post.new(level, GridPosition.of_key(key), base, owner, army, ours))
	DartSort.sort(posts, func(a: Post, b: Post) -> int:
		var by_strength := DartNum.compare_to(a.strength, b.strength)
		if by_strength != 0:
			return by_strength
		var by_level := DartSort.compare_ints(a.level, b.level)
		if by_level != 0:
			return by_level
		return a.at.y - b.at.y if a.at.y != b.at.y else a.at.x - b.at.x)
	return posts


## The cells of `level` the fog of `me` has shown, once each in the order
## first revealed, as Dart's `toSet()` keeps them.
static func _seen(me: Player, level: int) -> Array[Vector2i]:
	var seen: Dictionary[Vector2i, bool] = {}
	for key: Vector2i in GridPosition.keys(me.revealed_cells_on_level(level)):
		seen[key] = true
	var keys: Array[Vector2i] = []
	keys.assign(seen.keys())
	return keys
