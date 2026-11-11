class_name FactionBrain
extends GameScript
## lib/domain/faction/faction_brain.dart: what a faction plays: the whole game
## of a careful player, from the first building to the volcanic kernel at
## level 10 (ConquestStrategy), and now and then an attack on the weakest
## base or post it knows (FactionWar).
##
## The traits of the personality bend it (FactionTraits); it only uses the
## actions of the game, with their costs and checks.

var personality: FactionPersonality.Value


func _init(personality_: FactionPersonality.Value) -> void:
	personality = personality_


func name() -> String:
	return "faction-" + DartEnum.name_of(FactionPersonality.Value, personality)


func play_turn(turn: ScriptTurn) -> void:
	var traits := FactionTraits.of(personality)
	FactionWar.play(turn, personality)
	ConquestStrategy.new(
		null,  # planner
		traits.conquest_share,
		true,  # hunts_lairs
		traits.defends,
		true,  # guards_kernel
		false,  # contests
		true,  # chases_wrecks
		true,  # hunts_under_raid
		traits.growth,
		traits.explorers,
		FactionScouting.deep_scouts_of(personality),
		FactionScouting.DEEP_EXPLORERS,
		true,  # scouts_ahead
		FactionExploration.for_turn,
		true,  # besieges_held_kernel
		FactionResearch.plan_of(personality),
		FactionResearch.picks_of(personality),
		"faction",
	).play_turn(turn)
	FactionWarRecruit.play(turn, traits)
	FactionKernelGuard.play(turn, traits.guard_share)
