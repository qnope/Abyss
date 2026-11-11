class_name ResourceTexts
extends RefCounted
## lib/presentation/extensions/resource_type_extensions.dart
## (ResourceTypeInfo, ResourceGainsLabel): the resources' names and flavour
## texts, in the language on.


## `type.displayName(l10n)`: "Algues".
static func display_name(type: ResourceType.Value) -> String:
	return Texts.t(TextKeys.of("resource", ResourceType.Value, type, "Name"))


## `type.flavorText(l10n)`.
static func flavor_text(type: ResourceType.Value) -> String:
	return Texts.t(TextKeys.of("resource", ResourceType.Value, type, "Flavor"))


## `gains.gainLabel(l10n)`, the gains in the order of the map:
## "+30 corail, +20 minerai". What was not gained is left out.
static func gain_label(gains: Dictionary[ResourceType.Value, int]) -> String:
	var parts := PackedStringArray()
	for type: ResourceType.Value in gains:
		if gains[type] > 0:
			parts.append("+%d %s" % [gains[type], display_name(type).to_lower()])
	return ", ".join(parts)
