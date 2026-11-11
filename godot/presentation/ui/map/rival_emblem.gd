class_name RivalEmblem
extends RefCounted
## The emblem of a faction (lib/presentation/widgets/faction/faction_emblem.dart,
## `FactionEmblem.assetOf`): assets/icons/factions/<personality>.svg.


## The file of the emblem of the faction of [param personality].
static func path_of(personality: FactionPersonality.Value) -> String:
	var constant: String = FactionPersonality.Value.find_key(personality)
	return UiIcon.path_of(&"factions", StringName(constant.to_lower()))
