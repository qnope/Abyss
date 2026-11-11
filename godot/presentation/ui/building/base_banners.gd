class_name BaseBanners
extends RefreshingPanel
## The banners at the top of the base: the worksites still free this turn
## and, once the Coral Citadel stands, the rampart under them
## (lib/presentation/widgets/base/base_hud.dart). They let the touches through
## to the world under them; [method refresh] redraws them from the player.

var worksite_badge: WorksiteBadge
var shield_badge: ShieldBadge


func _init(player: Player) -> void:
	super()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	worksite_badge = WorksiteBadge.new(player.worksite, player.buildings)
	shield_badge = ShieldBadge.new(player.buildings)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(worksite_badge)
	column.add_child(shield_badge)
	add_child(column)


func refresh() -> void:
	# Called once by the base class, before there are badges.
	if shield_badge == null:
		return
	worksite_badge.refresh()
	shield_badge.refresh()
