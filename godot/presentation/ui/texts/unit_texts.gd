class_name UnitTexts
extends RefCounted
## lib/presentation/extensions/unit_type_extensions.dart (UnitTypeExtensions):
## the names and the roles of the units, in the language on.


## `type.displayName(l10n)`: "Éclaireur".
static func display_name(type: UnitType.Value) -> String:
	return Texts.t(TextKeys.of("unit", UnitType.Value, type, "Name"))


## `type.units(l10n, count)`: "3 éclaireurs".
static func units(type: UnitType.Value, count: int) -> String:
	return Texts.t(TextKeys.of("unit", UnitType.Value, type, "Count"), {"count": count})


## `type.role(l10n)`.
static func role(type: UnitType.Value) -> String:
	return Texts.t(TextKeys.of("unit", UnitType.Value, type, "Role"))


## `type.roleEffect(l10n)`.
static func role_effect(type: UnitType.Value) -> String:
	return Texts.t(TextKeys.of("unit", UnitType.Value, type, "RoleEffect"))
