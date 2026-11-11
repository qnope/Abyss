class_name KitParts
extends RefCounted
## The components of the UI kit, built with sample data for the review renders
## of KitGallery. Review tooling, not game code.

var _warn := UiIcon.glyph_path(&"warning")


func page_a() -> Array[Control]:
	var pills := HBoxContainer.new()
	pills.add_theme_constant_override(&"separation", 8)
	pills.add_child(StatusPill.new("VICTOIRE", AbyssColors.SUCCESS))
	pills.add_child(StatusPill.new("DÉFAITE", AbyssColors.ERROR))
	pills.add_child(StatusPill.new("PERDU", AbyssColors.ERROR, true))
	pills.add_child(CountBadge.new(3, AbyssColors.BIOLUM_CYAN))
	var items: Array[SegmentItem] = [
		SegmentItem.new(0, "Base", "Base", "4"), SegmentItem.new(1, "Carte", "Carte"),
		SegmentItem.new(2, "Armée", "Armée", "12"),
	]
	return [
		pills,
		NoticeBanner.new(_warn, AbyssColors.WARNING, "Votre base n'est pas défendue."),
		ThreatBanner.new(_warn, "Raid imminent", "Dans 2 tours", AbyssColors.ERROR, true),
		ThreatBanner.new(UiIcon.glyph_path(&"info"), "Banc de proies", "Rien à signaler",
			AbyssColors.BIOLUM_TEAL),
		SegmentedBar.new(items, 1),
		LabeledSwitch.new("Conseils", "Quelques indications de temps en temps.", true),
		LabeledSwitch.new("Guide du tutoriel", "Montre ce qu'il faut toucher.", false),
		LoreText.new("Les abysses écoutent ceux qui descendent."),
		LoreText.new("Le Volcan dort.", HORIZONTAL_ALIGNMENT_CENTER, LoreText.SMALL),
	]


func page_b() -> Array[Control]:
	var types := HBoxContainer.new()
	for type: ResourceType.Value in ResourceType.Value.values():
		types.add_child(ResourceIcon.new(type, 32.0))
	var techs := HBoxContainer.new()
	var event_icons := HBoxContainer.new()
	for tech: StringName in [&"military_1", &"explorer_2a", &"resources_5"]:
		techs.add_child(UiIcon.new(UiIcon.path_of(&"tech", tech), 48.0))
	for event: StringName in [&"storm", &"caravan"]:
		event_icons.add_child(UiIcon.new(UiIcon.path_of(&"events", event), 96.0))
	event_icons.add_child(UiIcon.new(UiIcon.path_of(&"guide", &"octopus_archivist"), 96.0))
	var portraits := HBoxContainer.new()
	for name_text: String in ["Quartier Général", "Ferme d'algues", "Éclaireur", "Kraken"]:
		portraits.add_child(Portrait.new(name_text, 64.0, AbyssColors.ORE_BLUE))
	for row: HBoxContainer in [types, techs, event_icons, portraits]:
		row.add_theme_constant_override(&"separation", 12)
	var halo := GuideHalo.new(_button("Construire"), true)
	halo.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var tab := TabPlaceholder.new(UiIcon.path_of(&"tech", &"explorer_1"), "Tech")
	tab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return [types, techs, event_icons, portraits, halo, tab]


func dialog() -> AbyssDialog:
	var built := AbyssDialog.new("Terminer le tour ?")
	var line := Label.new()
	line.text = "Les productions seront ajoutées à vos stocks."
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	built.body.add_child(line)
	built.add_action("Annuler")
	built.add_action("Confirmer", true, &"")
	return built


func sheet() -> BottomSheet:
	var built := BottomSheet.new()
	built.body.add_child(NoticeBanner.new(_warn, AbyssColors.WARNING, "Améliorer coûte 120 corail."))
	built.body.add_child(_button("Améliorer"))
	return built


func full_page() -> FullPage:
	var built := FullPage.new("Historique")
	built.body.add_child(LoreText.new("Rien ne s'est encore passé."))
	return built


func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	return button
