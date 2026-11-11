class_name KernelDescent
extends RefCounted
## The GDScript twin of test/helpers/kernel_descent_helper.dart: a KernelWar
## where the attacker holds the Faille and the Cheminée with their passages,
## so its army can go from the base to the volcano level in one turn; it has
## seen the kernel the owner holds at `kernel_level` with a small garrison.

var war: KernelWar


func _init(kernel_level: int) -> void:
	war = KernelWar.new(kernel_level)
	war.garrison(KernelWar.SMALL_GARRISON)
	_hold(TransitionBaseType.Value.FAILLE, 1, BuildingType.Value.DESCENT_MODULE)
	_hold(TransitionBaseType.Value.CHEMINEE, 2, BuildingType.Value.PRESSURE_CAPSULE)


## The FactionTurn of the attacker, its seeds `Random(3)`.
func turn() -> ScriptTurn:
	return FactionTurn.new(war.game, war.attacker(), ActionExecutor.new(), DartRandom.new(3, false))


## Puts `units` on `level` of the attacker.
func put(level: int, units: Dictionary[UnitType.Value, int]) -> void:
	war.put(war.attacker(), level, units)


## Units of `type` the attacker has on `level`.
func count(level: int, type: UnitType.Value) -> int:
	return war.count(war.attacker(), level, type)


func _hold(kind: TransitionBaseType.Value, level: int, passage: BuildingType.Value) -> void:
	var map: GameMap = war.game.levels[level]
	for y: int in map.height:
		for x: int in map.width:
			var base := map.cell_at(x, y).transition_base
			if base == null or base.type != kind:
				continue
			base.captured_by = war.attacker().id
			war.attacker().add_revealed_cell(level, GridPosition.new(x, y))
			war.attacker().buildings[passage] = Building.new(passage, 1)
			return
	push_error("KernelDescent: no %s on level %d" % [DartEnum.name_of(TransitionBaseType.Value, kind), level])
