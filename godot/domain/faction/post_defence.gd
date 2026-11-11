class_name PostDefence
extends RefCounted
## lib/domain/faction/post_defence.dart: what the human knows of the defence
## of a post it holds: the largest faction army its scouts reported, and what
## it loses if the post falls. Only what the human can know: nothing hidden
## by the fog leaks in.

## The strongest known threat; null when no report tells of one.
var threat: PostThreat
## The building destroyed with the post (a BuildingType.Value); null while it
## is not built.
var passage: Variant
## Units on the level below, lost with the post.
var units_below: int
## Units on their way to the level below, cancelled with the post.
var reinforcements: int


func _init(threat_: PostThreat, passage_: Variant, units_below_: int, reinforcements_: int) -> void:
	threat = threat_
	passage = passage_
	units_below = units_below_
	reinforcements = reinforcements_


## The defence of `post`, held by `human`, in `game`.
static func of(game: Game, human: Player, post: TransitionBase) -> PostDefence:
	var below := post.target_level()
	var units := 0
	for u: Unit in human.units_on_level(below).values():
		units += u.count
	var heading := 0
	for o: ReinforcementOrder in human.pending_reinforcements:
		if o.to_level == below:
			for n: int in o.units.values():
				heading += n
	return PostDefence.new(
		_threat_to(game, human, post),
		PostTakeover.passage_of(post.type) if PostTakeover.passage_built(human, post.type) else null,
		units,
		heading,
	)


## The reports tell of the armies on the factions' bases, on level 1: a
## threat to a Faille only.
static func _threat_to(game: Game, human: Player, post: TransitionBase) -> PostThreat:
	if post.type != TransitionBaseType.Value.FAILLE:
		return null
	var largest: PostThreat = null
	for faction: Faction in game.factions():
		var player: Player = game.players.get(faction.id())
		var report: BaseIntel = human.intel().get(faction.id())
		if player == null or player.has_fallen() or report == null:
			continue
		var units := 0
		for n: int in report.army.values():
			units += n
		if units == 0 or units <= (largest.units if largest != null else 0):
			continue
		largest = PostThreat.new(faction, units, report.turn, game.turn - report.turn)
	return largest
