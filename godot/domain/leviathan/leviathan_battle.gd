class_name LeviathanBattle
extends RefCounted
## lib/domain/leviathan/leviathan_battle.dart: fights the guardians that come
## back to the human's Faille, held by the units of the level it opens onto,
## without rampart, as against a faction. A lost fight costs the Faille like
## a post taken (PostTakeover), but the guardians hold it again, for anyone
## to take back with an admiral.


## Fights at the end of `turn`; the report is also kept in the human's
## history, so the end of the turn and a replay report the same fight. The
## fight and the wounded draw from `random` in that order, each from a die
## of its own when null.
static func fight(game: Game, post: TransitionBase, turn: int, random: DartRandom = null) -> FactionAttackReport:
	var human := game.human_player()
	var defence := BaseDefence.post(human, post.target_level())
	var result := FightEngine.new(random).resolve(LeviathanForce.of(game), defence.side)
	var outcome := defence.settle(human, random)
	var entry := PostAssaultSettlement.settle(
		turn, post, null, LeviathanForce.ATTACKER_NAME, human,
		AttackBaseResult.success(
			result.is_victory(), result, {}, {}, {}, {}, outcome, BaseDamage.none(human)
		),
	)
	return FactionAttackReport.new(LeviathanForce.ATTACKER_NAME, LeviathanForce.ATTACKER_NAME, null, entry)
