class_name WorksiteBadge
extends RefreshingPanel
## "Chantiers libres : X/Y": the building upgrades still allowed this turn.
## With [member show_next] it also tells which headquarters level opens the
## next one (lib/presentation/widgets/building/worksite_badge.dart). It reads
## the worksite and the buildings it is given as they change, and redraws on
## [method refresh].

var worksite: Worksite
var buildings: Dictionary[BuildingType.Value, Building]
var show_next: bool
var badge: InfoBadge


func _init(
	worksite_: Worksite, buildings_: Dictionary[BuildingType.Value, Building], show_next_ := false
) -> void:
	super()
	worksite = worksite_
	buildings = buildings_
	show_next = show_next_
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge = InfoBadge.new(UiIcon.glyph_path(&"construction"), AbyssColors.BIOLUM_CYAN, "")
	add_child(badge)
	refresh()


func refresh() -> void:
	# Called once by the base class, before there is a badge to write.
	if badge == null:
		return
	var hq := Building.level_in(buildings, BuildingType.Value.HEADQUARTERS)
	var free := worksite.free_build_sites(hq)
	var text := Texts.t(&"baseWorksitesFree", {"free": free, "total": WorksiteRules.build_sites(hq)})
	var next: Variant = WorksiteRules.next_site_at_hq(hq)
	if show_next and next != null:
		text += " · " + Texts.t(&"baseWorksitesNext", {"level": next})
	badge.show_text(text, AbyssColors.BIOLUM_CYAN if free > 0 else AbyssColors.WARNING)
