class_name TemporaryObjectiveTexts
extends RefCounted
## lib/presentation/extensions/temporary_objective_kind_extensions.dart: the
## objectives an event sets for a while, as the banner and the sheet word them.


## `kind.shortLabel(l10n)`: "Épave", for the objective banner.
static func short_label(kind: TemporaryObjectiveKind.Value) -> String:
	return Texts.t(TextKeys.of("temporaryObjective", TemporaryObjectiveKind.Value, kind, "Short"))


## `objective.displayTitle(l10n)`: "Repousse le banc de prédateurs".
static func display_title(objective: TemporaryObjective) -> String:
	var args := {"turn": objective.last_turn} if objective.kind == TemporaryObjectiveKind.Value.WRECK else {}
	return Texts.t(TextKeys.of("temporaryObjective", TemporaryObjectiveKind.Value, objective.kind, "Title"), args)
