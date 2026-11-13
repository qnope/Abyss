class_name MapTestCase
extends TestCase
## The base of the tests of the map: a small level of bare plain cells to put
## contents on, with the cells seen to choose, as the Dart tests do through
## test/helpers/map_tab_harness.dart.

const Content := CellContentType.Value
const Kind := MapContent.Kind


## The state of a level of [param width] by [param height] bare cells, the
## cells [param seen] revealed (the whole map when [param all]).
func level_of(width := 6, height := 6, seen: Array[Vector2i] = [], all := false,
		level := 1) -> MapLevelState:
	var state := MapLevelState.new(level, MapSamples.plain_map(width, height), "me")
	for y in height:
		for x in width:
			if all or seen.has(Vector2i(x, y)):
				state.revealed[Vector2i(x, y)] = true
	return state


## Puts a cell holding [param content] at ([param x], [param y]) of [param state].
func put(state: MapLevelState, x: int, y: int, content: Content, changes := {}) -> MapCell:
	var cell := MapCell.new(TerrainType.Value.PLAIN, content).copy_with(changes)
	state.map.set_cell(x, y, cell)
	return cell


## The look of the cell ([param x], [param y]) of [param state].
func look_at(state: MapLevelState, x: int, y: int) -> MapLook:
	return MapLooks.of(state)[y * state.map.width + x]


## A node of the scene, mounted under the tree's root and freed after the test.
func mounted(node: Node) -> Node:
	(Engine.get_main_loop() as SceneTree).root.add_child(node)
	add_cleanup(node.free)
	return node


## What the layers of [param part] draw: by the name of each, its mesh, then
## where each of its pieces lies.
func laid(part: Node) -> Dictionary[StringName, Array]:
	var found: Dictionary[StringName, Array] = {}
	for layer: MultiMeshInstance3D in part.get_children():
		var drawn: Array = [layer.multimesh.mesh]
		for index in layer.multimesh.instance_count:
			drawn.append(layer.multimesh.get_instance_transform(index))
		found[layer.name] = drawn
	return found
