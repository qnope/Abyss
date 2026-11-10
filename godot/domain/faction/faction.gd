class_name Faction
extends RefCounted
## lib/domain/faction/faction.dart: a rival of the human player. It is only a
## name and a personality: the faction itself plays as a regular Player of
## the game, whose id is id().

var personality: FactionPersonality.Value


func _init(personality_: FactionPersonality.Value) -> void:
	personality = personality_


## Id of the faction's player; stable, so a replay finds it again.
func id() -> String:
	return "faction-" + DartEnum.name_of(FactionPersonality.Value, personality)


func name() -> String:
	return FactionPersonality.label(personality)
