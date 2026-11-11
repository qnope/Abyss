class_name GuideAlerts
extends RefCounted
## lib/domain/objective/guide/guide_alerts.dart: what the guide says before
## the current objective, whatever it is: a kraken wave the garrison of the
## kernel would not hold, then a post held with nobody to defend it.


## The most urgent alert for `player` on objective `id`, null when nothing
## threatens what they hold.
static func of(game: Game, player: Player, id: ObjectiveId.Value) -> GuideAdvice:
	var wave := _wave(game, player)
	return wave if wave != null else _undefended(game, player, id)


## A wave announced against a garrison too small to hold it.
static func _wave(game: Game, player: Player) -> GuideAdvice:
	var wave := player.volcano_state.incoming
	if not player.volcano_state.is_incoming() or wave == null:
		return null
	var kernel := GuideMap.held_kernel(game, player)
	if kernel == null:
		return null
	var needed: Variant = KernelDefenceAdvisor.units_for(player, wave)
	if needed != null and needed <= KernelGarrison.size_of(player):
		return null
	return GuideAdvice.new(GuideKernelWave.new(wave.total_count(), needed), kernel)


## A post held with nobody below (UndefendedPosts: its passage built),
## unless the objective already asks to go down there.
static func _undefended(game: Game, player: Player, id: ObjectiveId.Value) -> GuideAdvice:
	for post: TransitionBase in UndefendedPosts.of(game, player):
		if id == _descent_to(post.target_level()):
			continue
		var cell := GuideMap.post_cell(game, post)
		return GuideAdvice.new(
			GuidePostUndefended.new(post.type, post.target_level()),
			cell if cell != null else GuideTarget.for_map()
		)
	return null


static func _descent_to(level: int) -> ObjectiveId.Value:
	return ObjectiveId.Value.DESCEND_LEVEL_2 if level == 2 else ObjectiveId.Value.DESCEND_LEVEL_3
