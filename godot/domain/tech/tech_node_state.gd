class_name TechNodeState
extends RefCounted
## lib/domain/tech/tech_node_state.dart: how a node of the research reef is
## drawn. DISCARDED is the option of a choice the player did not take.

enum Value {
	LOCKED,
	ACCESSIBLE,
	RESEARCHED,
	DISCARDED,
}
