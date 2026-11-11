extends TestCase
## The greyscale of an icon (RasterSvg's greyscale, raster_svg.dart).


func test_a_greyed_item_wears_the_greyscale_shader() -> void:
	var icon := ResourceIcon.new(ResourceType.Value.ALGAE)
	add_cleanup(icon.free)
	Greyscale.apply(icon)
	var grey := icon.material as ShaderMaterial
	assert_not_null(grey)
	assert_eq(grey.shader, Greyscale.SHADER)
	assert_true(Greyscale.SHADER.code.contains("luma"), "the shader greys the colour")


func test_an_item_taken_out_of_the_grey_has_its_colours_back() -> void:
	var icon := ResourceIcon.new(ResourceType.Value.ALGAE)
	add_cleanup(icon.free)
	Greyscale.apply(icon)
	Greyscale.apply(icon, false)
	assert_null(icon.material)
