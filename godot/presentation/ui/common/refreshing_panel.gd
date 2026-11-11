class_name RefreshingPanel
extends PanelContainer
## The base of the panels that write texts: [method refresh] rewrites
## everything that depends on the state or on the language, and the panel
## calls it itself when the language changes (NOTIFICATION_TRANSLATION_CHANGED,
## which the TranslationServer sends to every node). One mechanism for both:
## whoever changes the state calls refresh(), the language needs no one.
##
## A subclass fills itself in _init and ends it with refresh(), so it is
## complete once built; refresh() only sets texts and states, never adds a
## node. The panel draws nothing by default (BarePanel): a subclass picks its
## own look with theme_type_variation. Godot's own translation of texts is
## switched off under it: a text is written by [Texts], once, and again here.


func _init() -> void:
	theme_type_variation = AbyssSurfaceTheme.BARE
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		refresh()


## Rewrites the texts and states from the current state and language.
func refresh() -> void:
	pass
