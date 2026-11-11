class_name FactionPersonalityTexts
extends RefCounted
## lib/presentation/extensions/faction_personality_extensions.dart: where a
## faction comes from, in the language on.


## `personality.origin(l10n)`: the ship its crew sank with, and what it kept of
## it, e.g. "Un monastère flottant : …".
static func origin(personality: FactionPersonality.Value) -> String:
	return Texts.t(TextKeys.of("factionOrigin", FactionPersonality.Value, personality))
