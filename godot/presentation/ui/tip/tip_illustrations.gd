class_name TipIllustrations
extends RefCounted
## The picture on the card of a tip (lib/presentation/extensions/
## tip_id_extensions.dart, `illustration`): the building, the unit, the event,
## the post or the faction it explains, the guide's portrait when none fits.
## Buildings, units, posts and monsters are [Portrait]s until the renders of
## the 3D models replace them; events, factions and the guide are icons.

const Id := TipId.Value
const GUIDE := GuideBubble.PORTRAIT
const HOSTILE := "res://assets/icons/factions/murena_horde.svg"
const NEUTRAL := "res://assets/icons/factions/pearl_order.svg"

const BUILDINGS: Dictionary[TipId.Value, BuildingType.Value] = {
	Id.WORKSITES: BuildingType.Value.HEADQUARTERS,
	Id.TECH_CHOICE: BuildingType.Value.LABORATORY,
	Id.LAST_CHANCE: BuildingType.Value.CORAL_CITADEL,
	Id.DESCENT: BuildingType.Value.DESCENT_MODULE,
	Id.POST_DEFENCE: BuildingType.Value.DESCENT_MODULE,
	Id.KERNEL_GARRISON: BuildingType.Value.VOLCANIC_KERNEL,
}
const UNITS: Dictionary[TipId.Value, UnitType.Value] = {
	Id.RAID_REPORT: UnitType.Value.HARPOONIST,
	Id.FACTION_ATTACK: UnitType.Value.GUARDIAN,
	Id.ADMIRAL: UnitType.Value.ABYSS_ADMIRAL,
}
const ICONS: Dictionary[TipId.Value, String] = {
	Id.POST_LOST: HOSTILE,
	Id.RIVAL_COLONIES: NEUTRAL,
	Id.TRANSITION_BASE: GUIDE,
	Id.EVENTS: GUIDE,
}


## The picture of the tip [param id], [param size] points across.
func of(id: TipId.Value, size: float) -> Control:
	if BUILDINGS.has(id):
		return Portrait.new(BuildingTexts.display_name(BUILDINGS[id]), size)
	if UNITS.has(id):
		return Portrait.new(UnitTexts.display_name(UNITS[id]), size)
	if ICONS.has(id):
		return UiIcon.new(ICONS[id], size)
	var event: Variant = DartEnum.by_name(RandomEventType.Value, DartEnum.name_of(TipId.Value, id))
	if event != null:
		var type: RandomEventType.Value = event
		return UiIcon.new(RandomEventTexts.illustration(type), size)
	if id == Id.ANCIENTS:
		return PostPicture.of(TransitionBaseType.Value.FAILLE, PostHolder.Value.HUMAN, size)
	if id == Id.FORGE_TOWERS:
		return PostPicture.of(TransitionBaseType.Value.CHEMINEE, PostHolder.Value.GUARDIANS, size)
	return Portrait.new(TipTexts.title(id), size, AbyssColors.WARNING)
