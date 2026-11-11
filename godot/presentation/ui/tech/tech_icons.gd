class_name TechIcons
extends RefCounted
## The pictures of the research: one icon per node (assets/icons/tech/, the 21
## technologies) and one emblem per branch (tech_branch_extensions.dart:
## iconPath, tech_node_extensions.dart: nodeIconPath). Flutter draws the
## military branch with the barracks and the explorer with the scout, which
## are the world's and have no SVG here: the military branch wears the shield
## glyph and the explorer the compass one, tinted with the branch's colour; the
## resources branch keeps the algae icon.


## The file of the icon of the node of [param level] of [param branch];
## [param option] is the TechOption of a choice level, null on the others.
static func node_path(branch: TechBranch.Value, level: int, option: Variant = null) -> String:
	return UiIcon.path_of(&"tech", node_key(branch, level, option))


## "military_2a", "explorer_5": the name of a node's file.
static func node_key(branch: TechBranch.Value, level: int, option: Variant = null) -> String:
	return "%s_%s" % [DartEnum.name_of(TechBranch.Value, branch), node_id(level, option)]


## "2a", "5": a node in its branch, as TechNodeTexts.NODES lists them.
static func node_id(level: int, option: Variant = null) -> String:
	if option == null:
		return str(level)
	var taken: int = option
	return str(level) + DartEnum.name_of(TechOption.Value, taken)


## The emblem of [param branch], [param icon_size] points across, in
## [param color] (the algae keep their own).
static func branch_icon(branch: TechBranch.Value, icon_size: float, color: Color) -> UiIcon:
	match branch:
		TechBranch.Value.MILITARY:
			return UiIcon.glyph(&"shield", icon_size, color)
		TechBranch.Value.RESOURCES:
			return ResourceIcon.new(ResourceType.Value.ALGAE, icon_size)
	return UiIcon.glyph(&"explore", icon_size, color)
