class_name OpeningStoryModal
extends ModalPanel
## The opening story told again from the settings, over the game: the same
## cards, the last one's button, "Fermer", closing it
## (lib/presentation/widgets/opening/opening_story.dart: showOpeningStory).

var pager: StoryPager


func _init() -> void:
	super()
	placement = Placement.CENTER
	pager = StoryPager.new(OpeningStory.pages, &"commonClose")
	pager.done.connect(close)
	add_child(pager)
