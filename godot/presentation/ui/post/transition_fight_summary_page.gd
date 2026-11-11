class_name TransitionFightSummaryPage
extends AssaultSummaryPage
## The report of the assault on a Faille or a Cheminée
## (lib/presentation/screens/game/fight/transition_fight_summary_screen.dart):
## "Assault (x, y)", and "base captured" when the post was taken.

var result: AttackTransitionBaseResult
var target_x: int
var target_y: int


## The report of [param result_], of the assault on the cell ([param x],
## [param y]).
func _init(result_: AttackTransitionBaseResult, x: int, y: int) -> void:
	result = result_
	target_x = x
	target_y = y
	super(func() -> String: return Texts.t(&"fightAssaultTitle", {"x": x, "y": y}), &"fightBaseCaptured",
		result_.victory, result_.captured, result_.fight, result_.sent, result_.survivors_intact,
		result_.wounded, result_.dead)
