extends RefCounted
## The backdrop of a level round the review board (grid_view.gd): the pieces
## of assets/models/map_backdrop_<level>.glb as the game will repeat them, the
## rim's straight pieces (Edge1, Edge2: 2 long, outward +z) along each side, a
## Corner at each corner, and the other nodes (the silhouettes) beyond the rim.

const PIECE := 2.0
## Quarter turns round the board for the sides and corners: south (the front,
## the pieces as modelled), west, north, east.
const SIDES: Array[float] = [0.0, -90.0, 180.0, 90.0]


## The pieces' places round a board [param side] cells wide (even): each a
## [Transform3D] for the node of [param kinds] ("Edge" or "Corner").
static func places(side: int, kind: String) -> Array[Transform3D]:
	var found: Array[Transform3D] = []
	var half := side / 2.0
	for turn in SIDES:
		var basis := Basis(Vector3.UP, deg_to_rad(turn))
		if kind == "Corner":
			found.append(Transform3D(basis, basis * Vector3(half, 0.0, half)))
			continue
		for index in side / int(PIECE):
			var along := -half + PIECE / 2.0 + PIECE * index
			found.append(Transform3D(basis, basis * Vector3(along, 0.0, half)))
	return found


## Stands the backdrop [param scene] (the glb's root) round [param floor_], a
## board [param side] cells wide.
static func dress(floor_: Node3D, scene: Node3D, side: int) -> void:
	var edges: Array[Mesh] = []
	for piece_name: String in ["Edge1", "Edge2"]:
		edges.append((scene.get_node(NodePath(piece_name)) as MeshInstance3D).mesh)
	var corner := (scene.get_node("Corner") as MeshInstance3D).mesh
	var edge_places := places(side, "Edge")
	for index in edge_places.size():
		floor_.add_child(_piece(edges[index % 2], edge_places[index]))
	for at in places(side, "Corner"):
		floor_.add_child(_piece(corner, at))
	var far: Array[MeshInstance3D] = []
	for child in scene.get_children():
		if child is MeshInstance3D and not (child.name as String).begins_with("Edge") \
				and child.name != &"Corner":
			far.append(child as MeshInstance3D)
	var spots: Array[Vector3] = [Vector3(-side * 0.3, 0.0, -side / 2.0 - 5.0),
		Vector3(side * 0.3, 0.0, -side / 2.0 - 6.0), Vector3(-side / 2.0 - 5.0, 0.0, side * 0.2)]
	for index in far.size():
		floor_.add_child(_piece(far[index].mesh, Transform3D(Basis.IDENTITY, spots[index % spots.size()])))


static func _piece(mesh: Mesh, at: Transform3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.transform = at
	return instance
