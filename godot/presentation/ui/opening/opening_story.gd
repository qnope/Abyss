class_name OpeningStory
extends RefCounted
## The story told by the octopus archivist as a game begins: the Great
## Sinking, the abyss that listens, the cold Core, then the goal
## (lib/presentation/widgets/opening/opening_story.dart: openingStoryPages).
## The pictures are the renders of the colony's dome, of the swarm and of the
## Core, and the archivist's own icon.

const PICTURE_SIZE := 160.0
const GUIDE_ICON := "res://assets/icons/guide/octopus_archivist.svg"


## The four pages in the language on.
static func pages() -> Array[StoryPage]:
	var found: Array[StoryPage] = []
	found.append(_page(_portrait.bind(BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS),
		PortraitFiles.building(BuildingType.Value.HEADQUARTERS)), &"openingSinking"))
	found.append(_page(_portrait.bind(MonsterFamilyTexts.label(MonsterFamily.Value.SWARM),
		PortraitFiles.monster(MonsterFamily.Value.SWARM)), &"openingListens"))
	found.append(_page(_portrait.bind(BuildingTexts.display_name(BuildingType.Value.VOLCANIC_KERNEL),
		PortraitFiles.building(BuildingType.Value.VOLCANIC_KERNEL)), &"openingCore"))
	found.append(_page(func() -> Control: return UiIcon.new(GUIDE_ICON, PICTURE_SIZE), &"openingGoal"))
	return found


## The page whose texts are `<prefix>Title`, `<prefix>Line1` and `<prefix>Line2`.
static func _page(make_picture: Callable, prefix: String) -> StoryPage:
	return StoryPage.new(make_picture, Texts.t(StringName(prefix + "Title")), PackedStringArray([
		Texts.t(StringName(prefix + "Line1")), Texts.t(StringName(prefix + "Line2"))]))


static func _portrait(named: String, picture: String) -> Control:
	return Portrait.new(named, PICTURE_SIZE, AbyssColors.BIOLUM_CYAN, picture)
