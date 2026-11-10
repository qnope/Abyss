class_name TemporaryObjectiveOutcome
extends RefCounted
## `TemporaryObjectiveOutcome` of
## lib/domain/objective/temporary/temporary_objective_end.dart: how a
## temporary objective ended. DONE: reached in time. EXPIRED: its last turn
## went by before it was reached. FAILED: lost for good, like a fight lost.

enum Value { DONE, EXPIRED, FAILED }
