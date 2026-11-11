class_name BaseTarget
extends RefCounted
## lib/domain/faction/faction_base_targets.dart: a base a faction could
## attack, with what its scouts reported of it.

var player: Player
## What the scouts reported of the base.
var intel: BaseIntel
## How hard the defence the report shows hits back at the army.
var strength: float


func _init(player_: Player, intel_: BaseIntel, ours: Array[Combatant]) -> void:
	player = player_
	intel = intel_
	strength = ArmyPlanner.strength(BaseDefence.from_intel(intel_).side, ours)
