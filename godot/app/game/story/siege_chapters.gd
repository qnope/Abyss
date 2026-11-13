class_name SiegeChapters
extends RefCounted
## The sieges a turn tells (lib/presentation/screens/game/story/attack_chapter.dart
## and turn_story.dart): a raid, a school of predators or a kraken wave against
## the human's base or volcano, and the attack of a faction (or of the guardians)
## on its base, one of its posts or its volcano. Each is a [MapSiege] of the
## place, on its level, or null when no map holds the place.


## The siege of the base by the wave of [param report], a raid or the predators.
## The human's side defends there, so the rounds are its own.
static func raid(game: Game, report: RaidReport) -> StoryChapter:
	var human := game.human_player()
	var siege := MapSiege.by_wave(Vector2i(human.base_x, human.base_y), report.wave, report.fight, report.victory)
	siege.rounds = StrikeRounds.of(report.fight)
	return StoryChapter.new(1, siege)


## The siege of the volcano by the kraken wave of [param report].
static func volcano(game: Game, report: VolcanoReport) -> StoryChapter:
	var found: Variant = _kernel(game)
	if found == null:
		return null
	var kernel: Vector2i = found
	var siege := MapSiege.by_wave(kernel, report.wave, report.fight, report.victory, VolcanicKernelPlacer.SIDE)
	siege.rounds = StrikeRounds.of(report.fight)
	return StoryChapter.new(KernelGarrison.VOLCANO_LEVEL, siege)


## The siege of what [param attack] struck: the attackers' fight is seen from the
## side that held.
static func attack(game: Game, attack_: FactionAttackReport) -> StoryChapter:
	var human := game.human_player()
	var level := 1
	var at: Variant = Vector2i(human.base_x, human.base_y)
	var span := 1
	match attack_.target():
		AttackTarget.Value.KERNEL:
			level = KernelGarrison.VOLCANO_LEVEL
			at = _kernel(game)
			span = VolcanicKernelPlacer.SIDE
		AttackTarget.Value.POST:
			var post := attack_.post()
			var found: Variant = StoryPlaces.post_of(game, post) if post != null else null
			if found == null:
				return null
			var post_at: Vector3i = found
			level = post_at.x
			at = Vector2i(post_at.y, post_at.z)
	if at == null:
		return null
	var place: Vector2i = at
	var fight := attack_.entry.fight_result
	var held := not attack_.entry.victory
	var rounds := StrikeRounds.defence_of(fight)
	var lead: Variant = StrikeLead.of(_sent(fight))
	var ring := MapPalette.DAMAGE
	if attack_.personality != null:
		var personality: FactionPersonality.Value = attack_.personality
		ring = FactionColors.of(personality)
	var siege := MapSiege.new(place, held, _attacker(lead), ring, span, rounds)
	return StoryChapter.new(level, siege)


## The volcano of the human's, else the first.
static func _kernel(game: Game) -> Variant:
	var map: GameMap = game.levels.get(KernelGarrison.VOLCANO_LEVEL)
	return StoryPlaces.kernel_of(map, game.human_player_id)


## The army the attackers sent in [param fight]: how many of each unit.
static func _sent(fight: FightResult) -> Dictionary[UnitType.Value, int]:
	var sent: Dictionary[UnitType.Value, int] = {}
	for combatant in fight.initial_player_combatants:
		var found: Variant = CombatantBuilder.unit_type_from_key(combatant.type_key)
		if found != null:
			var type: UnitType.Value = found
			sent[type] = sent.get(type, 0) + 1
	return sent


## What stands for the attackers: a figure of the unit they sent the most of, or
## a kraken for the guardians, who send none.
static func _attacker(lead: Variant) -> Callable:
	if lead == null:
		return func() -> Node3D: return MonsterFigure.new(MonsterFamily.Value.KRAKEN, MonsterDifficulty.Value.HARD)
	var type: UnitType.Value = lead
	return func() -> Node3D: return WorldModels.unit(type)
