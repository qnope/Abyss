class_name GuideController
extends RefCounted
## The glue of the guide's rings: what the tutorial points at
## ([member GuideScope.advice]) is ringed on the floor of the world, where the
## 2D halos cannot reach. A building is ringed on its pad of the base, a unit on
## its squad of the parade ground, a cell of the map (a post to take, the
## volcano) on the map. The rings of the rest are put away.

var _scope: GuideScope
var _world: WorldHost


func _init(scope: GuideScope, world: WorldHost) -> void:
	_scope = scope
	_world = world
	_scope.changed.connect(aim)
	aim()


## The screen is gone: the rings are put away.
func close() -> void:
	_scope.changed.disconnect(aim)
	_world.base.guide.clear()
	_world.parade.guide.clear()
	_world.map.guide.release()


## Rings what the guide points at now.
func aim() -> void:
	var target := _scope.target()
	_aim_base(target)
	_aim_parade(target)
	_aim_map(target)


func _aim_base(target: GuideTarget) -> void:
	var ring := _world.base.guide
	if target == null or target.building == null:
		ring.clear()
		return
	var type: BuildingType.Value = target.building
	var pad := BaseBuildings.pad_of(type)
	ring.point_at(_world.base.pads.origin_of(pad), _world.base.pads.radius_of(pad), BuildingTexts.display_name(type))


func _aim_parade(target: GuideTarget) -> void:
	var ring := _world.parade.guide
	if target == null or target.unit == null:
		ring.clear()
		return
	var type: UnitType.Value = target.unit
	var at := _world.parade.squads[type].position
	ring.point_at(at, ParadeLayout.PAD * ParadeLayout.CELL / 2.0, UnitTexts.display_name(type))


func _aim_map(target: GuideTarget) -> void:
	if target == null or target.cell == null:
		_world.map.guide.release()
		return
	var level: int = target.level
	_world.map.guide.aim(level, target.cell.x, target.cell.y)
