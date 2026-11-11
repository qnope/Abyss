class_name TechTreeView
extends VBoxContainer
## The research tree of the laboratory tab: the laboratory at the head, the
## three branches under it, each a column of medallion and nodes
## (lib/presentation/widgets/tech/tech_tree_view.dart and tech_reef.dart). While
## the laboratory stands to build, a notice says that it is the first thing to
## do. It is built from a [TechView] and tells what is touched with
## [signal target_tapped]; the tab opens the panel of the target and builds the
## tree again after each change.

## The player touched a branch's medallion or one of its nodes.
signal target_tapped(target: TechTarget)

const GAP := 12
const COLUMNS_GAP := 8

var view: TechView
var lab: TechLabEmblem
## Why nothing can be researched yet, null once the laboratory stands.
var notice: NoticeBanner
var columns: Dictionary[TechBranch.Value, TechBranchColumn] = {}


func _init(view_: TechView, guide: GuideScope = null) -> void:
	view = view_
	add_theme_constant_override(&"separation", GAP)
	if view.lab_level < 1:
		notice = NoticeBanner.new(UiIcon.glyph_path(&"lock"), AbyssColors.WARNING,
			Texts.t(&"techScreenLabRequired", {"level": TechCostCalculator.required_lab_level(1)}))
		add_child(notice)
	lab = TechLabEmblem.new(view.lab_level)
	lab.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(lab)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", COLUMNS_GAP)
	for branch: TechBranch.Value in TechBranch.Value.values():
		var column := TechBranchColumn.new(branch, view, guide)
		column.target_tapped.connect(target_tapped.emit)
		columns[branch] = column
		row.add_child(column)
	add_child(row)


## The node of [param level] of [param branch]; [param option] is the
## TechOption of a choice level, null on the others.
func node_at(branch: TechBranch.Value, level: int, option: Variant = null) -> TechNode:
	return columns[branch].node_at(level, option)
