class_name StrikeEffectCase
extends TestCase
## The base of the tests of a strike played on the map: a strike on a cell of an
## 8 by 8 map, over a content the test holds, and what it needs to look at.

var _made: Array[Node] = []
var _content_made: MeshInstance3D


func after_each() -> void:
	for node in _made:
		node.free()


func _effect(victory := true, lair: MonsterLair = null, span := 1) -> StrikeEffect:
	var strike := StrikeSamples.strike(Vector2i(3, 3), victory, lair, span)
	var geometry := StrikeGeometry.new(Vector2i(0, 5), strike.target, 8, 8, span)
	return _mount(StrikeEffect.new(strike, geometry, _content()))


func _mount(effect: StrikeEffect) -> StrikeEffect:
	(Engine.get_main_loop() as SceneTree).root.add_child(effect)
	_made.append(effect)
	return effect


func _content() -> Node3D:
	var content := Node3D.new()
	_content_made = MeshInstance3D.new()
	_content_made.mesh = BoxMesh.new()
	content.add_child(_content_made)
	_made.append(content)
	return content


func _overlay() -> Color:
	return (_content_made.material_overlay as StandardMaterial3D).albedo_color


func _lair() -> MonsterLair:
	return StrikeSamples.lair(MonsterFamily.Value.HUNTER)
