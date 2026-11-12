class_name MonsterFigure
extends Node3D
## The monsters of a lair, as they show on the map when a fight is played: the
## model of their family (`assets/models/swarm.glb`, `hunter.glb`...) or the
## generic one (the Rôdeurs of games started before the families, or a family with
## no model), scaled to stand on a cell 1 m wide (the models are drawn at the
## size of a scene of their own: the Kraken is 8 m across, a swarm's fish 0.6 m
## long) and a little bigger the harder the lair. A swarm is a small school, the
## others one figure. Every model faces -Z, the way a unit does; its origin is
## the floor under it. [method play] plays an animation on all of them.

const MODELS: Dictionary[MonsterFamily.Value, PackedScene] = {
	MonsterFamily.Value.SWARM: preload("res://assets/models/swarm.glb"),
	MonsterFamily.Value.ARMOURED: preload("res://assets/models/armoured.glb"),
	MonsterFamily.Value.HUNTER: preload("res://assets/models/hunter.glb"),
	MonsterFamily.Value.COLOSSUS: preload("res://assets/models/colossus.glb"),
	MonsterFamily.Value.KRAKEN: preload("res://assets/models/kraken.glb"),
}
const GENERIC: PackedScene = preload("res://assets/models/monster_generic.glb")
## How much each model is scaled so that it is about a cell long, by family.
const SCALES: Dictionary[MonsterFamily.Value, float] = {
	MonsterFamily.Value.SWARM: 0.85,
	MonsterFamily.Value.ARMOURED: 0.3,
	MonsterFamily.Value.HUNTER: 0.3,
	MonsterFamily.Value.COLOSSUS: 0.24,
	MonsterFamily.Value.KRAKEN: 0.2,
}
const GENERIC_SCALE := 0.56
## How much bigger the harder the lair, and how many fish a swarm shows.
const GROWTH: Dictionary[MonsterDifficulty.Value, float] = {
	MonsterDifficulty.Value.EASY: 0.85,
	MonsterDifficulty.Value.MEDIUM: 1.0,
	MonsterDifficulty.Value.HARD: 1.15,
}
const FISH: Dictionary[MonsterDifficulty.Value, int] = {
	MonsterDifficulty.Value.EASY: 3,
	MonsterDifficulty.Value.MEDIUM: 4,
	MonsterDifficulty.Value.HARD: 5,
}
## Where the fish of a swarm swim, from the middle of the cell.
const SCHOOL: Array[Vector2] = [
	Vector2(0.0, 0.0), Vector2(-0.28, 0.2), Vector2(0.3, 0.15), Vector2(-0.12, -0.28), Vector2(0.18, -0.3),
]

## The models standing, one for a monster, several for a swarm.
var models: Array[Node3D] = []
var _animators: Array[ModelAnimator] = []


## The monsters of [param family] (a MonsterFamily.Value, or null for the generic
## ones) of a lair of [param difficulty].
func _init(family: Variant, difficulty: MonsterDifficulty.Value) -> void:
	name = &"Monster"
	var scene := GENERIC
	var scale_ := GENERIC_SCALE
	if family != null:
		var known: MonsterFamily.Value = family
		scene = MODELS[known]
		scale_ = SCALES[known]
	var count := FISH[difficulty] if family == MonsterFamily.Value.SWARM else 1
	for index in count:
		var model := scene.instantiate() as Node3D
		model.scale = Vector3.ONE * scale_ * GROWTH[difficulty]
		model.position = Vector3(SCHOOL[index].x, 0.0, SCHOOL[index].y) if count > 1 else Vector3.ZERO
		add_child(model)
		models.append(model)
		_animators.append(ModelAnimator.new(model))


## Plays [param animation] on every model, [param speed] times as fast as its own.
func play(animation: StringName, speed := 1.0) -> void:
	for animator in _animators:
		animator.play(animation, speed)


## How long [param animation] lasts, in seconds, at its own speed; 0 if the
## models have none.
func length_of(animation: StringName) -> float:
	return _animators[0].length_of(animation)
