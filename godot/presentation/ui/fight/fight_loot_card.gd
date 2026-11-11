class_name FightLootCard
extends ResourceTallyCard
## The resources won in a fight, or that there were none
## (lib/presentation/widgets/fight/fight_loot_card.dart).


func _init(loot: Dictionary[ResourceType.Value, int]) -> void:
	super(&"fightLoot", AbyssColors.BIOLUM_CYAN, &"fightNoLoot", loot, "+")
