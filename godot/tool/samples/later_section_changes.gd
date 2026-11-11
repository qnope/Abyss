class_name LaterSectionChanges
extends RefCounted
## test/domain/reference/later_section_changes.dart: the changes of the
## sections of what happens to a player, threats, objectives, scouts'
## reports and history (SectionChanges).


static func all() -> Dictionary[String, Array]:
	var wave := MonsterLair.new(MonsterDifficulty.Value.HARD, 4)
	return {
		"raids": [
			func(g: Game) -> void: g.human_player().raid_state.add_noise(3),
			func(g: Game) -> void: g.human_player().raid_state.announce(wave, 9),
			func(g: Game) -> void: g.human_player().raid_state.record_outcome(false),
			func(g: Game) -> void: g.human_player().raid_state.record_outcome(true),
			func(g: Game) -> void: g.human_player().raid_state.kernel_siege_lost_turn = 3,
			func(g: Game) -> void: SectionChanges.rival_of(g).raid_state.post_attack_turns[g.human_player_id] = 3,
			func(g: Game) -> void: SectionChanges.rival_of(g).raid_state.kernel_attack_turns[g.human_player_id] = 3,
			func(g: Game) -> void: g.human_player().raid_state.attacks.append(AnnouncedAttack.new(
				SectionChanges.rival_of(g).id, {UnitType.Value.HARPOONIST: 5} as Dictionary[UnitType.Value, int], 4, 99,
			)),
		],
		"volcano": [
			func(g: Game) -> void: g.human_player().volcano_state.announce(wave, 9),
			func(g: Game) -> void: g.human_player().volcano_state.record_outcome(true),
			func(g: Game) -> void: g.human_player().volcano_state.record_outcome(false),
		],
		"events": [
			func(g: Game) -> void: g.human_player().event_state.schedule(6),
			func(g: Game) -> void: g.human_player().event_state.heating = true,
			func(g: Game) -> void: g.human_player().event_state.predator_wave = wave,
			func(g: Game) -> void: g.human_player().event_state.wreck_position = GridPosition.new(1, 2),
			func(g: Game) -> void: g.human_player().event_state.trade_from = ResourceType.Value.ORE,
		],
		"objectives": [
			func(g: Game) -> void: g.human_player().saved_objective_state.complete(ObjectiveId.Value.HQ_LEVEL_1),
			func(g: Game) -> void: g.human_player().saved_objective_state.mark_seen(0 as TipId.Value),
			func(g: Game) -> void: g.human_player().saved_objective_state.tutorial_enabled = true,
			func(g: Game) -> void: SectionChanges.rival_of(g).saved_objective_state = null,
		],
		"intel": [
			func(g: Game) -> void: SectionChanges.rival_of(g).intel()[g.human_player_id] = BaseIntel.new(
				2, 1, 0, {UnitType.Value.SCOUT: 2} as Dictionary[UnitType.Value, int],
				{ResourceType.Value.ALGAE: 10} as Dictionary[ResourceType.Value, int],
			),
		],
		"history": [
			func(g: Game) -> void: g.human_player().add_history_entry(HistorySamples.turn_end_entry(1)),
			func(g: Game) -> void: SectionChanges.rival_of(g).add_history_entry(HistorySamples.combat_entry(true)),
		],
	}
