class_name PassagePicture
extends RefCounted
## The picture of the arrival of a passage (lib/presentation/extensions/
## post_holder_extensions.dart, `passageIllustration`), lit by whoever holds
## the post at the same place on the level above, as the player sees it: the
## guardians of a post not taken, the player, a rival.


## The picture of the passage at ([param x], [param y]) of [param level].
static func of(game: Game, level: int, x: int, y: int, size := 64.0) -> Portrait:
	var name_text := PassageName.of(game.levels[level].cell_at(x, y).passage_name)
	return Portrait.new(name_text, size, tint_of(_holder(game, level, x, y)))


## Who holds the post above the passage: the guardians when there is none.
static func _holder(game: Game, level: int, x: int, y: int) -> PostHolder.Value:
	var above: GameMap = game.levels.get(level - 1)
	var base: TransitionBase = null if above == null else above.cell_at(x, y).transition_base
	if base == null:
		return PostHolder.Value.GUARDIANS
	return PostHolder.of(base, game.human_player().id)


## The colour of the post of [param holder]: cyan for the player's, pink for a
## rival's, dim for the guardians'.
static func tint_of(holder: PostHolder.Value) -> Color:
	match holder:
		PostHolder.Value.HUMAN:
			return AbyssColors.BIOLUM_CYAN
		PostHolder.Value.FACTION:
			return AbyssColors.BIOLUM_PINK
	return AbyssColors.ON_SURFACE_DIM
