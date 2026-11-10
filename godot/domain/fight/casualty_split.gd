class_name CasualtySplit
extends RefCounted
## lib/domain/fight/casualty_split.dart: the fallen of a fight, those who
## come back wounded and those who do not.

var wounded: Array[Combatant]
var dead: Array[Combatant]


func _init(wounded_: Array[Combatant], dead_: Array[Combatant]) -> void:
	wounded = wounded_
	dead = dead_
