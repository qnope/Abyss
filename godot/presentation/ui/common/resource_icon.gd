class_name ResourceIcon
extends UiIcon
## The icon of a resource (lib/presentation/widgets/resource/resource_icon.dart):
## algae, coral, ore, energy or pearl, 24 points across unless told.

var type: ResourceType.Value


func _init(resource: ResourceType.Value, icon_size := 24.0) -> void:
	super(path_for(resource), icon_size)
	type = resource


## The file of [param resource]'s icon: assets/icons/resources/<name>.svg.
static func path_for(resource: ResourceType.Value) -> String:
	return UiIcon.path_of(&"resources", DartEnum.name_of(ResourceType.Value, resource))
