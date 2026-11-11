extends UiTestCase
## The base of the panels that write texts: it refreshes when asked and when
## the language changes, the same way, and draws nothing of its own.


## A panel showing the "coming soon" text and counting its refreshes.
class Probe:
	extends RefreshingPanel

	var shown := Label.new()
	var refreshes := 0

	func _init() -> void:
		super()
		add_child(shown)
		refresh()

	func refresh() -> void:
		refreshes += 1
		shown.text = Texts.t(&"screenComingSoon")


func test_draws_nothing_and_leaves_the_translation_to_texts() -> void:
	var panel := RefreshingPanel.new()
	assert_eq(panel.theme_type_variation, &"BarePanel")
	assert_eq(panel.auto_translate_mode, Node.AUTO_TRANSLATE_MODE_DISABLED)
	panel.refresh()
	panel.free()


func test_is_complete_once_built() -> void:
	var probe := Probe.new()
	assert_eq(probe.shown.text, "Bientôt disponible")
	probe.free()


func test_refreshes_when_the_state_changes() -> void:
	var probe := mount(Probe.new()) as Probe
	var before := probe.refreshes
	probe.refresh()
	assert_eq(probe.refreshes, before + 1)


func test_refreshes_once_when_the_language_changes() -> void:
	var probe := mount(Probe.new()) as Probe
	var before := probe.refreshes
	use_language("en")
	assert_eq(probe.refreshes, before + 1)
	assert_eq(probe.shown.text, "Coming soon")
	use_language("es")
	assert_eq(probe.shown.text, "Próximamente")
	assert_eq(probe.refreshes, before + 2)


func test_a_language_change_reaches_a_panel_nested_deep() -> void:
	var outer := mount(VBoxContainer.new())
	var inner := Probe.new()
	var row := HBoxContainer.new()
	outer.add_child(row)
	row.add_child(inner)
	use_language("en")
	assert_eq(inner.shown.text, "Coming soon")
