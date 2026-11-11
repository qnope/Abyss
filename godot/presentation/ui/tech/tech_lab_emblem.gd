class_name TechLabEmblem
extends VBoxContainer
## The laboratory at the head of the tree, where every branch springs from
## (TechReef._lab in lib/presentation/widgets/tech/tech_reef.dart): its
## picture, teal once built and grey while it stands to build, and its level.

const SIZE := 56.0
const GAP := 4

var built: bool
var portrait: Portrait
var level_label := Label.new()


func _init(lab_level: int) -> void:
	built = lab_level > 0
	add_theme_constant_override(&"separation", GAP)
	var tint := AbyssColors.BIOLUM_TEAL if built else AbyssColors.DISABLED
	portrait = Portrait.new(BuildingTexts.display_name(BuildingType.Value.LABORATORY), SIZE, tint)
	level_label.text = Texts.t(&"baseLevel", {"level": lab_level}) if built else Texts.t(&"baseNotBuilt")
	level_label.theme_type_variation = &"BodySmall"
	level_label.add_theme_color_override(&"font_color", tint)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(portrait)
	add_child(level_label)
