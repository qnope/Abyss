class_name GuideCampaign
extends RefCounted
## lib/domain/objective/guide/guide_campaign.dart: the guide past the
## tutorial chapter: the rift, the chimney and the kernel step by step, and
## the alerts of GuideAlerts from the rift on. The reef says nothing, the
## awakening only its alerts.

const _HQ_TYPE := BuildingType.Value.HEADQUARTERS
const _Id := ObjectiveId.Value


## The advice for `player` on `objective`, null when the guide is silent.
static func of(game: Game, player: Player, objective: Objective) -> GuideAdvice:
	if objective.chapter < ObjectiveChapter.Value.RIFT:
		return null
	var id := objective.id
	var alert := GuideAlerts.of(game, player, id)
	if alert != null:
		return alert
	var step := _step(game, player, id)
	if step == null:
		return null
	if objective.is_done(game, player):
		return GuideAdvice.new(GuideGoalMet.new(), GuideTarget.for_end_turn())
	var busy := GuideBusy.of(player, step.target)
	var advice := busy if busy != null else step
	var assault: Variant = _assault_of(id)
	if assault == null:
		return advice
	var target: AssaultTarget.Value = assault
	if GuideAssault.admiral_fell(game, player, target):
		return GuideAdvice.new(GuideAdmiralFell.new(target), advice.target)
	return advice


static func _step(game: Game, player: Player, id: ObjectiveId.Value) -> GuideAdvice:
	var assault: Variant = _assault_of(id)
	if assault != null:
		var target: AssaultTarget.Value = assault
		return GuideAssault.of(game, player, target)
	match id:
		_Id.DESCENT_MODULE:
			return _passage(player, id, BuildingType.Value.DESCENT_MODULE)
		_Id.PRESSURE_CAPSULE:
			return _passage(player, id, BuildingType.Value.PRESSURE_CAPSULE)
		_Id.DESCEND_LEVEL_2:
			return _descent(game, player, id, 1)
		_Id.DESCEND_LEVEL_3:
			return _descent(game, player, id, 2)
		_Id.HQ_LEVEL_8, _Id.HQ_LEVEL_10:
			return GuideAdvice.new(GuideLesson.new(id), _hq())
		_Id.KERNEL_LEVEL_1:
			return GuideAdvice.new(GuideLesson.new(id), GuideTarget.for_building(BuildingType.Value.VOLCANIC_KERNEL))
	return null


## The AssaultTarget.Value of objective `id`, or null.
static func _assault_of(id: ObjectiveId.Value) -> Variant:
	match id:
		_Id.TAKE_FAILLE:
			return AssaultTarget.Value.FAILLE
		_Id.TAKE_CHEMINEE:
			return AssaultTarget.Value.CHEMINEE
		_Id.TAKE_KERNEL:
			return AssaultTarget.Value.KERNEL
	return null


## The headquarters `passage` needs, then its card.
static func _passage(player: Player, id: ObjectiveId.Value, passage: BuildingType.Value) -> GuideAdvice:
	var needed: int = BuildingCostCalculator.new().prerequisites(passage, 1).get(_HQ_TYPE, 0)
	if Building.level_in(player.buildings, _HQ_TYPE) < needed:
		return GuideAdvice.new(GuidePassageNeedsHq.new(passage, needed), _hq())
	return GuideAdvice.new(GuideLesson.new(id), GuideTarget.for_building(passage))


## The post held on `from` to go down by.
static func _descent(game: Game, player: Player, id: ObjectiveId.Value, from: int) -> GuideAdvice:
	var post := GuideMap.held_post_on(game, player, from)
	return GuideAdvice.new(GuideLesson.new(id), post if post != null else GuideTarget.for_map())


static func _hq() -> GuideTarget:
	return GuideTarget.for_building(_HQ_TYPE)
