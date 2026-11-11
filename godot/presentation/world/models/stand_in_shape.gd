class_name StandInShape
extends RefCounted
## What a building looks like until its model exists: one primitive solid,
## told from the others by its kind and its proportions. [member size] is the
## width, the height and the depth of the box that holds it, in metres, on a
## pad 1.9 wide (the headquarters' 2.9).

enum Kind { BOX, CYLINDER, PRISM, CAPSULE, TORUS, SPHERE }

var kind: Kind
var size: Vector3
## For a cylinder, the share of the base's width the top keeps.
var taper: float


func _init(kind_: Kind, size_: Vector3, taper_ := 1.0) -> void:
	kind = kind_
	size = size_
	taper = taper_


## The shape of the building [param type].
static func of(type: BuildingType.Value) -> StandInShape:
	match type:
		BuildingType.Value.HEADQUARTERS:
			return StandInShape.new(Kind.CYLINDER, Vector3(1.8, 2.4, 1.8), 0.8)
		BuildingType.Value.ALGAE_FARM:
			return StandInShape.new(Kind.CYLINDER, Vector3(1.7, 0.4, 1.7))
		BuildingType.Value.CORAL_MINE:
			return StandInShape.new(Kind.PRISM, Vector3(1.4, 1.5, 1.2))
		BuildingType.Value.CORAL_CITADEL:
			return StandInShape.new(Kind.BOX, Vector3(1.3, 1.9, 1.3))
		BuildingType.Value.ORE_EXTRACTOR:
			return StandInShape.new(Kind.CYLINDER, Vector3(1.5, 0.9, 1.5), 0.6)
		BuildingType.Value.SOLAR_PANEL:
			return StandInShape.new(Kind.BOX, Vector3(1.6, 0.25, 1.1))
		BuildingType.Value.LABORATORY:
			return StandInShape.new(Kind.CAPSULE, Vector3(1.1, 1.7, 1.1))
		BuildingType.Value.BARRACKS:
			return StandInShape.new(Kind.PRISM, Vector3(1.7, 0.9, 1.4))
		BuildingType.Value.DESCENT_MODULE:
			return StandInShape.new(Kind.TORUS, Vector3(1.7, 0.5, 1.7))
		BuildingType.Value.PRESSURE_CAPSULE:
			return StandInShape.new(Kind.CAPSULE, Vector3(0.76, 2.3, 0.76))
	return StandInShape.new(Kind.SPHERE, Vector3(1.6, 1.6, 1.6))


## The shape of the unit [param type], smaller than a building's: told from
## the five others by its kind, a figure of the squad.
static func of_unit(type: UnitType.Value) -> StandInShape:
	match type:
		UnitType.Value.SCOUT:
			return StandInShape.new(Kind.SPHERE, Vector3(0.6, 0.6, 0.6))
		UnitType.Value.HARPOONIST:
			return StandInShape.new(Kind.PRISM, Vector3(0.55, 1.3, 0.55))
		UnitType.Value.GUARDIAN:
			return StandInShape.new(Kind.BOX, Vector3(0.8, 0.9, 0.5))
		UnitType.Value.DOME_BREAKER:
			return StandInShape.new(Kind.CYLINDER, Vector3(0.8, 0.7, 0.8), 0.6)
		UnitType.Value.ABYSS_ADMIRAL:
			return StandInShape.new(Kind.CAPSULE, Vector3(0.7, 1.6, 0.7))
	return StandInShape.new(Kind.TORUS, Vector3(0.9, 0.3, 0.9))


## A mesh of the solid, centred on its box.
func mesh() -> PrimitiveMesh:
	match kind:
		Kind.BOX:
			var box := BoxMesh.new()
			box.size = size
			return box
		Kind.CYLINDER:
			var cylinder := CylinderMesh.new()
			cylinder.bottom_radius = size.x / 2.0
			cylinder.top_radius = size.x / 2.0 * taper
			cylinder.height = size.y
			return cylinder
		Kind.PRISM:
			var prism := PrismMesh.new()
			prism.size = size
			return prism
		Kind.CAPSULE:
			var capsule := CapsuleMesh.new()
			capsule.radius = size.x / 2.0
			capsule.height = size.y
			return capsule
		Kind.TORUS:
			var torus := TorusMesh.new()
			torus.outer_radius = size.x / 2.0
			torus.inner_radius = size.x / 2.0 - size.y
			return torus
	var sphere := SphereMesh.new()
	sphere.radius = size.x / 2.0
	sphere.height = size.y
	return sphere
