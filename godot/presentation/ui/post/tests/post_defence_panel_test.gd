extends UiTestCase
## test/presentation/widgets/map/post_defence_panel_test.dart: what is known of
## the threat to a post the player holds, and what is lost should it fall.

const Faille := TransitionBaseType.Value.FAILLE
const Cheminee := TransitionBaseType.Value.CHEMINEE
const Module := BuildingType.Value.DESCENT_MODULE
const Capsule := BuildingType.Value.PRESSURE_CAPSULE


func _horde() -> PostThreat:
	return PostThreat.new(Faction.new(FactionPersonality.Value.MURENA_HORDE), 35, 21, 2)


func _panel(defence: PostDefence, kind := Faille) -> PostDefencePanel:
	return mount(PostDefencePanel.new(TransitionBase.new(kind, "F", "h"), defence)) as PostDefencePanel


func test_the_known_threat_is_shown_with_its_emblem() -> void:
	var panel := _panel(PostDefence.new(_horde(), Module, 0, 0))
	assert_eq(panel.threat_label.text, "La Horde des Murènes : 35 combattants (rapport du tour 21)")
	var icons := find_type("TextureRect", panel)
	assert_true(icons.any(func(icon: TextureRect) -> bool: return (icon as UiIcon).icon_path.ends_with("murena_horde.svg")))


func test_no_threat_known_shows_no_threat_line() -> void:
	var panel := _panel(PostDefence.new(null, Module, 0, 0))
	assert_null(panel.threat_label)
	assert_null(find_text("combattant", panel))


func test_everything_lost_when_a_faille_falls_is_listed() -> void:
	var panel := _panel(PostDefence.new(null, Module, 12, 3))
	assert_not_null(find_text("Si la Faille tombe", panel))
	assert_eq(PackedStringArray(panel.loss_labels.map(func(l: Label) -> String: return l.text)),
		PackedStringArray(["Module de descente détruit", "12 unités du niveau 2 perdues", "3 renforts en route annulés"]))
	assert_not_null(find_text("Les factions attaquent les postes sans prévenir.", panel))
	assert_no_raw_keys(panel)


func test_what_is_zero_is_left_out() -> void:
	var panel := _panel(PostDefence.new(null, Module, 0, 0))
	assert_eq(panel.loss_labels.size(), 1)
	panel = _panel(PostDefence.new(null, null, 2, 0))
	assert_eq(panel.loss_labels.size(), 1)
	assert_eq(panel.loss_labels[0].text, "2 unités du niveau 2 perdues")


func test_a_cheminee_names_its_capsule_and_level_3() -> void:
	var panel := _panel(PostDefence.new(null, Capsule, 1, 0), Cheminee)
	assert_not_null(find_text("Si la Cheminée tombe", panel))
	assert_eq(panel.loss_labels[0].text, "Capsule pressurisée détruite")
	assert_eq(panel.loss_labels[1].text, "1 unité du niveau 3 perdue")


func test_the_panel_speaks_english() -> void:
	var panel := _panel(PostDefence.new(_horde(), Module, 0, 1))
	use_language("en")
	assert_not_null(find_text("If the Rift falls", panel))
	assert_not_null(find_text("Descent Module destroyed", panel))
	assert_not_null(find_text("1 reinforcement on the way cancelled", panel))
	assert_no_raw_keys(panel)
