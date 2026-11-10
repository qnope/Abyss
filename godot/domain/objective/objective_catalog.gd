class_name ObjectiveCatalog
extends RefCounted
## lib/domain/objective/objective_catalog.dart: the main thread of
## objectives, from the first building to the victory. Dart keeps the list
## and its index in static finals; here each call builds them anew.


## Every objective, in the order they are given.
static func all() -> Array[Objective]:
	var objectives := InstallationObjectives.installation_objectives()
	objectives.append_array(CampaignObjectives.campaign_objectives())
	return objectives


## The objective of `id`. The catalog holds every id once, in the order of
## the enum (its test checks it): an id is its index, where Dart indexes the
## list in a map.
static func by_id(id: ObjectiveId.Value) -> Objective:
	return all()[id]


## The objectives of `chapter`, in order.
static func of_chapter(chapter: ObjectiveChapter.Value) -> Array[Objective]:
	var found: Array[Objective] = []
	for objective: Objective in all():
		if objective.chapter == chapter:
			found.append(objective)
	return found


## The first objective not in `completed`, a set of ids; null once all are.
static func first_not_done(completed: Dictionary[ObjectiveId.Value, bool]) -> Objective:
	for objective: Objective in all():
		if not completed.has(objective.id):
			return objective
	return null
