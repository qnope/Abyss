extends TestCase
## The interface icons of assets/icons/, copied from the Flutter assets:
## only the folders that are interface (never the world's buildings, units,
## monsters, terrain or decor), each file imported as a texture rasterised
## large with mipmaps, so that it stays crisp at any size it is drawn.

const ROOT := "res://assets/icons"
## The icons of each folder, and the size in pixels its files are rasterised
## at, from the viewBox (64, the glyphs' 24) and the import's svg/scale.
const FOLDERS := {
	"resources": [5, 256], "tech": [21, 256], "events": [7, 384], "factions": [10, 384],
	"guide": [1, 384], "ui": [11, 192],
}


func test_only_interface_folders_are_copied() -> void:
	var folders := Array(DirAccess.get_directories_at(ROOT))
	folders.erase("tests")
	folders.sort()
	var expected := FOLDERS.keys()
	expected.sort()
	assert_eq(folders, expected)


func test_each_folder_holds_the_icons_of_the_flutter_assets() -> void:
	for folder: String in FOLDERS:
		assert_eq(_icons(folder).size(), FOLDERS[folder][0], folder)


func test_the_resource_icons_are_named_as_the_resources() -> void:
	var names := Array(DartEnum.names(ResourceType.Value))
	names.sort()
	assert_eq(_icons("resources"), names)


func test_every_icon_is_rasterised_large_with_mipmaps() -> void:
	for folder: String in FOLDERS:
		for icon: String in _icons(folder):
			var path := "%s/%s/%s.svg" % [ROOT, folder, icon]
			var config := ConfigFile.new()
			assert_eq(config.load(path + ".import"), OK, path)
			var mipmaps: bool = config.get_value("params", "mipmaps/generate", false)
			assert_true(mipmaps, path)
			var texture := load(path) as Texture2D
			assert_not_null(texture, path)
			if texture != null:
				assert_eq(texture.get_size(), Vector2.ONE * FOLDERS[folder][1], path)


func _icons(folder: String) -> Array:
	var names := []
	for file in DirAccess.get_files_at("%s/%s" % [ROOT, folder]):
		if file.ends_with(".svg"):
			names.append(file.trim_suffix(".svg"))
	names.sort()
	return names
