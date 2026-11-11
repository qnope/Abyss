class_name TechBranchTexts
extends RefCounted
## lib/presentation/extensions/tech_branch_extensions.dart (TechBranchInfo):
## the names of the three branches of research, in the language on.


## `branch.displayName(l10n)`: "Militaire".
static func display_name(branch: TechBranch.Value) -> String:
	return Texts.t(TextKeys.of("techBranch", TechBranch.Value, branch, "Name"))


## `branch.description(l10n)`.
static func description(branch: TechBranch.Value) -> String:
	return Texts.t(TextKeys.of("techBranch", TechBranch.Value, branch, "Description"))
