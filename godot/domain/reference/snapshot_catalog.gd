class_name SnapshotCatalog
extends RefCounted
## lib/domain/reference/snapshot_catalog.dart: every class snapshot, one per
## persisted class of the model, so a test can check that none is missing
## and that each declares every field of its class.


static func all() -> Array[ClassSnapshot]:
	var found: Array[ClassSnapshot] = [
		GameSnapshots.game(),
		PlayerSnapshots.player(),
		PlayerSnapshots.objectives(),
		JournalSnapshots.journal(),
		BaseSnapshots.resource(),
		BaseSnapshots.building(),
		BaseSnapshots.tech_branch(),
		BaseSnapshots.unit(),
		BaseSnapshots.worksite(),
		MapSnapshots.position(),
		MapSnapshots.lair(),
		MapSnapshots.transition_base(),
		MapSnapshots.cell(),
		MapSnapshots.game_map(),
		MapSnapshots.exploration(),
		MapSnapshots.reinforcement(),
		ThreatSnapshots.attack(),
		ThreatSnapshots.raid(),
		ThreatSnapshots.volcano(),
		ThreatSnapshots.event(),
		ThreatSnapshots.leviathan(),
		ThreatSnapshots.intel(),
		FightSnapshots.combatant(),
		FightSnapshots.turn(),
		FightSnapshots.result(),
	]
	found.append_array(HistorySnapshots.all())
	return found
