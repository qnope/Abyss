class_name UndefendedPosts
extends RefCounted
## lib/domain/faction/undefended_posts.dart: the posts a player holds with
## nobody to defend them: a Faille with no unit on level 2, a Cheminée with
## none on level 3. Such a post falls to the first attack. A post whose
## passage building is not built yet is left out: nobody can go down to
## defend it.


## The posts `player` holds in `game` with no unit on the level they open
## onto and their passage built, the shallowest first.
static func of(game: Game, player: Player) -> Array[TransitionBase]:
	var posts: Array[TransitionBase] = []
	for map: GameMap in game.levels.values():
		for cell: MapCell in map.cells:
			var post := cell.transition_base
			if (
				post != null
				and post.captured_by == player.id
				and PostTakeover.passage_built(player, post.type)
				and not _defended(player, post.target_level())
			):
				posts.append(post)
	DartSort.sort(posts, func(a: TransitionBase, b: TransitionBase) -> int:
		return DartSort.compare_ints(a.target_level(), b.target_level()))
	return posts


static func _defended(player: Player, level: int) -> bool:
	for u: Unit in player.units_on_level(level).values():
		if u.count > 0:
			return true
	return false
