class_name TechNodeTexts
extends RefCounted
## lib/presentation/extensions/tech_node_extensions.dart (TechNodeInfo): name
## and effect of every node of the research reef. A node is a branch level,
## plus the TechOption on a choice level (2 and 4).

## The nodes of a branch, by level and option: "1", "2a", "2b", "3"...
const NODES: Array[String] = ["1", "2a", "2b", "3", "4a", "4b", "5"]
## The size of the explored area (`techExploredAreaEffect`) each plain level
## of the explorer branch gives.
const _EXPLORED_SIZE := {"1": 5, "3": 7, "5": 9}


## `branch.nodeName(l10n, level, option)`; "" for a node the reef lacks.
## `option` is a TechOption.Value, or null on a level without choice.
static func node_name(branch: TechBranch.Value, level: int, option: Variant = null) -> String:
	var node := _node(level, option)
	return Texts.t(_key(branch, node, "Name")) if NODES.has(node) else ""


## `branch.nodeEffect(l10n, level, option)`; "" for a node the reef lacks.
static func node_effect(branch: TechBranch.Value, level: int, option: Variant = null) -> String:
	var node := _node(level, option)
	if not NODES.has(node):
		return ""
	if node.length() == 2:
		return Texts.t(_key(branch, node, "Effect"))
	match branch:
		TechBranch.Value.MILITARY:
			return Texts.t(&"techTierEffect")
		TechBranch.Value.RESOURCES:
			return Texts.t(&"techProductionEffect")
	return Texts.t(&"techExploredAreaEffect", {"size": _EXPLORED_SIZE[node]})


## "1", "2a"...: the level followed by the Dart name of the option.
static func _node(level: int, option: Variant) -> String:
	if option == null:
		return str(level)
	var chosen: int = option
	return str(level) + DartEnum.name_of(TechOption.Value, chosen)


static func _key(branch: TechBranch.Value, node: String, suffix: String) -> StringName:
	return TextKeys.of("tech", TechBranch.Value, branch, node + suffix)
