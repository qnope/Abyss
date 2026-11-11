class_name BaseAssaultSummaryPage
extends AssaultSummaryPage
## The report of an assault on a base, a post or the kernel another player
## holds, read from the side of the owner of its entry: the attacker's own,
## just fought, or the defender's, in the history or in the turn summary
## (lib/presentation/screens/game/fight/base_assault_summary_screen.dart).
##
## It is the [AssaultSummaryPage] of a place the guardians hold, with the
## cards of a rival's: who attacked whom, the defenders put out of action, then
## what became of the place (the damage and the loot of a base, the post or
## the kernel taken). The result is the owner's: a defender whose attacker lost
## has won.

var entry: BaseAssaultEntry


func _init(entry_: BaseAssaultEntry) -> void:
	entry = entry_
	super(func() -> String: return Texts.t(&"fightAssaultOn", {"target": AttackerNameTexts.label(entry_.opponent_name)}),
		&"", entry_.victory != entry_.defending, false, entry_.fight_result, entry_.units,
		entry_.survivors_intact, entry_.wounded, entry_.dead)


func _lead() -> Control:
	var key := &"assaultAttackedYou" if entry.defending else &"assaultYouAttacked"
	return AssaultLineCard.new([func() -> String:
		return Texts.t(key, {"name": AttackerNameTexts.label(entry.opponent_name)})] as Array[Callable])


func _kill_count() -> Control:
	return FightKillCount.new(fight, false, &"assaultDefendersDown")


func _details() -> Array[Control]:
	var cards: Array[Control] = []
	if not entry.victory:
		return cards
	var code: Variant = entry.post_name
	if code == AttackHeldKernelAction.KERNEL_CODE:
		cards.append(AssaultKernelCard.new(entry))
	elif code != null:
		var post: String = code
		var key := &"assaultPostLost" if entry.defending else &"assaultPostTaken"
		cards.append(AssaultLineCard.new([func() -> String:
			return Texts.t(key, {"post": TransitionBaseNameTexts.label(post)})] as Array[Callable]))
	else:
		cards.append(AssaultDamageCard.new(entry))
		cards.append(RaidPillageCard.new(entry.pillaged) if entry.defending else FightLootCard.new(entry.loot))
	return cards
