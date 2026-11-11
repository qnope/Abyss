extends TipCase
## The picture on a tip's card: the thing it explains.


func _of(id: TipId.Value) -> Control:
	var picture := TipIllustrations.new().of(id, 36.0)
	add_cleanup(picture.free)
	return picture


func test_every_tip_has_a_picture_of_the_size_asked() -> void:
	for each in TipCatalog.all():
		assert_eq(_of(each.id).custom_minimum_size, Vector2(36, 36), str(each.id))


func test_a_building_a_unit_and_a_post_are_portraits_of_their_name() -> void:
	assert_eq((_of(Id.WORKSITES) as Portrait).display_name, BuildingTexts.display_name(BuildingType.Value.HEADQUARTERS))
	assert_eq((_of(Id.ADMIRAL) as Portrait).display_name, UnitTexts.display_name(UnitType.Value.ABYSS_ADMIRAL))
	assert_eq((_of(Id.ANCIENTS) as Portrait).display_name, TransitionBaseTexts.display_name(TransitionBaseType.Value.FAILLE))
	assert_eq((_of(Id.FORGE_TOWERS) as Portrait).display_name, TransitionBaseTexts.display_name(TransitionBaseType.Value.CHEMINEE))


func test_an_event_a_faction_and_the_guide_are_icons() -> void:
	assert_eq((_of(Id.STORM) as UiIcon).icon_path, RandomEventTexts.illustration(RandomEventType.Value.STORM))
	assert_eq((_of(Id.POST_LOST) as UiIcon).icon_path, TipIllustrations.HOSTILE)
	assert_eq((_of(Id.RIVAL_COLONIES) as UiIcon).icon_path, TipIllustrations.NEUTRAL)
	assert_eq((_of(Id.EVENTS) as UiIcon).icon_path, GuideBubble.PORTRAIT)


func test_a_monster_is_a_portrait_of_the_tips_name() -> void:
	assert_eq((_of(Id.LAIR) as Portrait).display_name, TipTexts.title(Id.LAIR))
