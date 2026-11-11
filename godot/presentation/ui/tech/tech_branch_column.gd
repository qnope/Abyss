class_name TechBranchColumn
extends VBoxContainer
## One branch of the tree, running down: its medallion, then its five nodes,
## the two levels of choice (2 and 4) showing their two options side by side,
## a thread between each. Flutter lays the three branches out as the spokes
## of a sonar around the laboratory (tech_reef.dart, tech_reef_geometry.dart);
## three columns read the same on a phone and need no painter. It is built from
## a [TechView] and tells what is touched with [signal target_tapped].

## The player touched the branch's medallion or one of its nodes.
signal target_tapped(target: TechTarget)

const NODE_SIZE := 44.0
const NODE_GAP := 12
const LINK_HEIGHT := 20.0

var branch: TechBranch.Value
var medallion: TechBranchMedallion
## The nodes by name: "1", "2a", "2b", "3", "4a", "4b", "5".
var nodes: Dictionary[String, TechNode] = {}
## The threads, the one above the node of each level first.
var links: Array[TechLink] = []


func _init(branch_: TechBranch.Value, view: TechView) -> void:
	branch = branch_
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override(&"separation", 0)
	var color := TechColors.of(branch)
	medallion = TechBranchMedallion.new(branch, view.is_unlocked(branch), view.research_level(branch))
	medallion.tapped.connect(target_tapped.emit.bind(TechTarget.new(branch)))
	add_child(medallion)
	for level in range(1, TechTree.MAX_LEVEL + 1):
		var link := TechLink.new(color, view.is_unlocked(branch) and view.research_level(branch) >= level - 1,
			LINK_HEIGHT)
		links.append(link)
		add_child(link)
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override(&"separation", NODE_GAP)
		for option: Variant in _options(level):
			var node := TechNode.new(branch, level, option, view.node_state(branch, level, option), NODE_SIZE)
			node.tapped.connect(target_tapped.emit.bind(TechTarget.new(branch, level)))
			nodes[TechIcons.node_id(level, option)] = node
			row.add_child(node)
		add_child(row)


## The node of [param level]; [param option] is the TechOption of a choice
## level, null on the others.
func node_at(level: int, option: Variant = null) -> TechNode:
	var node: TechNode = nodes.get(TechIcons.node_id(level, option))
	return node


## One node on a level of tier, the two options on a level of choice.
func _options(level: int) -> Array:
	return [TechOption.Value.A, TechOption.Value.B] if TechTree.is_choice_level(level) else [null]
