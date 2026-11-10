class_name GuideBusy
extends RefCounted
## lib/domain/objective/guide/guide_busy.dart: the worksite or the
## recruitment a target of the guide asks for, already used this turn: the
## guide then asks to end the turn.


## The advice to end the turn when `player` cannot touch `target` again this
## turn, null when they can.
static func of(player: Player, target: GuideTarget) -> GuideAdvice:
	var hq := Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS)
	if target.building != null and player.worksite.free_build_sites(hq) <= 0:
		return GuideAdvice.new(GuideWorksiteTaken.new(), GuideTarget.for_end_turn())
	if target.unit != null and player.recruited_unit_types.has(target.unit):
		return GuideAdvice.new(GuideAlreadyRecruited.new(), GuideTarget.for_end_turn())
	return null
