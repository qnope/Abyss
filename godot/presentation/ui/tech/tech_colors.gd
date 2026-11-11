class_name TechColors
extends RefCounted
## The colour of each branch of the research, in its medallion, its nodes and
## its panel (lib/presentation/extensions/tech_branch_extensions.dart:
## TechBranchColor).


## `branch.color`.
static func of(branch: TechBranch.Value) -> Color:
	match branch:
		TechBranch.Value.MILITARY:
			return AbyssColors.BIOLUM_PINK
		TechBranch.Value.RESOURCES:
			return AbyssColors.ALGAE_GREEN
	return AbyssColors.BIOLUM_CYAN
