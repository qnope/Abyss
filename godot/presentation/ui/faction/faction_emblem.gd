class_name FactionEmblem
extends UiIcon
## The emblem of a faction (lib/presentation/widgets/faction/faction_emblem.dart):
## its medallion, an interface icon of assets/icons/factions (see [RivalEmblem]
## for the file).

const DEFAULT_SIZE := 40.0

var personality: FactionPersonality.Value


func _init(personality_: FactionPersonality.Value, icon_size := DEFAULT_SIZE) -> void:
	personality = personality_
	super(RivalEmblem.path_of(personality_), icon_size)
