extends TestCase
## A flash of colour over a model.

var _node: Node3D
var _a: MeshInstance3D
var _b: MeshInstance3D
var _veil := StandardMaterial3D.new()


func before_each() -> void:
	_node = Node3D.new()
	_a = MeshInstance3D.new()
	_b = MeshInstance3D.new()
	_b.material_overlay = _veil
	_node.add_child(_a)
	_node.add_child(_b)
	add_cleanup(_node.free)


func test_a_flash_lays_one_translucent_material_over_every_mesh() -> void:
	var flash := HitFlash.new(_node)
	flash.show(Color.WHITE, 0.5)
	assert_not_null(_a.material_overlay)
	assert_eq(_a.material_overlay, _b.material_overlay)
	var material := _a.material_overlay as StandardMaterial3D
	assert_eq(material.albedo_color.a, 0.5)
	assert_eq(material.albedo_color.r, 1.0)


func test_a_stronger_flash_than_one_is_one() -> void:
	var flash := HitFlash.new(_node)
	flash.show(Color.WHITE, 3.0)
	assert_eq((_a.material_overlay as StandardMaterial3D).albedo_color.a, 1.0)


func test_no_strength_puts_back_what_each_mesh_wore() -> void:
	var flash := HitFlash.new(_node)
	flash.show(Color.WHITE, 0.5)
	flash.show(Color.WHITE, 0.0)
	assert_null(_a.material_overlay)
	assert_eq(_b.material_overlay, _veil)


func test_a_mesh_freed_meanwhile_is_left_alone() -> void:
	var flash := HitFlash.new(_node)
	_a.free()
	flash.show(Color.WHITE, 0.5)
	flash.clear()
	assert_eq(_b.material_overlay, _veil)


func test_a_flash_too_faint_to_see_puts_them_back_too() -> void:
	var flash := HitFlash.new(_node)
	flash.show(Color.WHITE, 0.5)
	flash.show(Color.WHITE, HitFlash.FAINT / 2.0)
	assert_null(_a.material_overlay)
