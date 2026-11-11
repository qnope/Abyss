class_name GuideCardHalo
extends GuidedHalo
## A [GuidedHalo] fitted to a card of the theme (lib/.../guide_card_halo.dart):
## its glow follows the rounded corners of the card's panel
## ([AbyssCardTheme.card]). Flutter also skips the margin around a card; a
## panel of the theme has none, so there is no inset to take off.
##
##     GuideCardHalo.new(card, scope, func(target: GuideTarget) -> bool: return target.is_unit(type))


func _init(card: Control, scope_: GuideScope, picks_: Callable) -> void:
	super(card, scope_, picks_, AbyssCardTheme.card().corner_radius_top_left)
