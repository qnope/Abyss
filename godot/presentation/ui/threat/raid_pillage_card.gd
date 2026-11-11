class_name RaidPillageCard
extends ResourceTallyCard
## The resources the monsters carried away after a lost raid
## (lib/presentation/screens/game/raid/raid_pillage_card.dart).


func _init(pillaged: Dictionary[ResourceType.Value, int]) -> void:
	super(&"raidPillage", AbyssColors.ERROR, &"raidNothingToLoot", pillaged, "-")
