class_name MapContents
extends Node3D
## What stands on the map's cells: for each look with a content, whatever
## [WorldModels.map_content] gives (a model or a stand-in), on the top of its
## tile. The volcano, which covers 2 x 2 cells, stands on the middle of them.
##
## The map is drawn again after each action of the player and each turn, and
## a level stands a few hundred contents, a scene each: a content stays, the
## very node, while what decides it does not change (its kind, its tint,
## whether it is dimmed, where it stands), and only one that appeared, changed
## or left is stood, replaced or freed. The children keep the order of the
## looks, as if all were stood afresh.

## What stands on each cell, by its key, in the order of the looks.
var by_cell: Dictionary[Vector2i, Node3D] = {}
## What decides each of them: see [method _deciding].
var _decided: Dictionary[Vector2i, Array] = {}
## Whether they cast shadows: only while the view is close ([MapCamera.zoomed]).
## From far a shadow is a few pixels of a few hundred nodes, and the pass that
## draws them costs as much as the contents themselves.
var _casting := false


## Stands the contents of [param looks] (the cells of a map [param width] by
## [param height]) in place of the ones standing before, keeping those that
## look the same: a content kept is in sight, whatever hid it.
func show_looks(looks: Array[MapLook], width: int, height: int) -> void:
	var asked := _deciding(looks, width, height)
	for key: Vector2i in by_cell.keys():
		if not asked.has(key) or asked[key] != _decided[key]:
			_free(by_cell[key])
			by_cell.erase(key)
	var standing: Dictionary[Vector2i, Node3D] = {}
	for key in asked:
		var content: Node3D = by_cell.get(key)
		if content == null:
			content = _stood(key, asked[key])
		content.visible = true
		move_child(content, standing.size())
		standing[key] = content
	by_cell = standing
	_decided = asked


## Lets the contents cast their shadows, or not.
func cast_shadows(enabled: bool) -> void:
	_casting = enabled
	for content in get_children():
		_cast(content)


## What decides the content of each cell of [param looks] that has one, by its
## key: its kind, its tint, whether it is dimmed, and where it stands (which
## its cell, its span, the height of its floor and the size of the map give).
static func _deciding(looks: Array[MapLook], width: int, height: int) -> Dictionary[Vector2i, Array]:
	var found: Dictionary[Vector2i, Array] = {}
	for look in looks:
		if look.content == null:
			continue
		var floor_ := WorldModels.terrain(look.terrain, look.revealed)
		found[look.key()] = [look.content, look.tint, look.dimmed,
			MapGrid.at(look.x, look.y, width, height)
			+ Vector3(1.0, 0.0, 1.0) * (look.span - 1) * MapGrid.CELL / 2.0
			+ Vector3.UP * floor_.height]
	return found


## Stands on the cell [param key] the content that [param deciding] tells.
func _stood(key: Vector2i, deciding: Array) -> Node3D:
	var kind: MapContent.Kind = deciding[0]
	var dimmed: bool = deciding[2]
	var content := WorldModels.map_content(kind, deciding[1], dimmed)
	content.name = "Cell%d_%d" % [key.x, key.y]
	content.position = deciding[3]
	add_child(content)
	_cast(content)
	return content


## Frees [param content], in the tree: a node with its own materials, freed
## outside it, makes the renderer complain. It complains too of one freed in
## the frame it was stood in: as an instance goes, the renderer brings up to
## date every instance changed since the last frame, this one among them, and
## reads its own materials (a tint, a veil), which went just before. So it is
## made to do so first, while they are whole: freeing an instance of its own
## does it.
static func _free(content: Node3D) -> void:
	RenderingServer.free_rid(RenderingServer.instance_create())
	content.free()


## Sets the shadows of [param content] and of every mesh in it as the contents'.
func _cast(content: Node) -> void:
	var mode := GeometryInstance3D.SHADOW_CASTING_SETTING_ON if _casting else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var meshes := content.find_children("*", "GeometryInstance3D", true, false)
	if content is GeometryInstance3D:
		meshes.append(content)
	for node: Node in meshes:
		(node as GeometryInstance3D).cast_shadow = mode
