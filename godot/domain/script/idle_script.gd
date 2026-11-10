class_name IdleScript
extends GameScript
## lib/domain/script/idle_script.dart: ends every turn without acting, the
## baseline every strategy should beat.


func name() -> String:
	return "idle"


func play_turn(_turn: ScriptTurn) -> void:
	pass
