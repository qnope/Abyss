class_name ObjectiveId
extends RefCounted
## lib/domain/objective/objective_id.dart: every objective of the main
## thread, in the order they are given. SOLAR_PANEL_LEVEL_2 was added after
## the others: a Hive save numbers it 24, which is not its place here.

enum Value {
	HQ_LEVEL_1,
	ALGAE_FARM,
	MINES,
	SOLAR_PANEL,
	HQ_LEVEL_2,
	BARRACKS_AND_SCOUTS,
	EXPLORE,
	SOLAR_PANEL_LEVEL_2,
	LABORATORY_AND_RESEARCH,
	FIRST_RAID,
	TAKE_LAIR,
	HQ_LEVEL_5,
	CORAL_CITADEL,
	TAKE_FAILLE,
	DESCENT_MODULE,
	DESCEND_LEVEL_2,
	HQ_LEVEL_8,
	TAKE_CHEMINEE,
	PRESSURE_CAPSULE,
	DESCEND_LEVEL_3,
	HQ_LEVEL_10,
	TAKE_KERNEL,
	KERNEL_LEVEL_1,
	KERNEL_LEVEL_5,
	KERNEL_LEVEL_10,
}
