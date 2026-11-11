class_name GameTab
extends RefCounted
## The four tabs of the game screen, in the order of the bottom bar: the base,
## the map, the army and the research
## (lib/presentation/screens/game/game_screen_tabs.dart, game_bottom_bar.dart).

enum Value { BASE, MAP, ARMY, TECH }

const ICONS: Dictionary[Value, StringName] = {
	Value.BASE: &"home", Value.MAP: &"map", Value.ARMY: &"shield", Value.TECH: &"science",
}
const KEYS: Dictionary[Value, StringName] = {
	Value.BASE: &"screenTabBase", Value.MAP: &"screenTabMap",
	Value.ARMY: &"screenTabArmy", Value.TECH: &"screenTabTech",
}


## The place of the guide's advice each tab opens (game_screen_tabs.dart: tabAreas).
const AREAS: Dictionary[Value, GuideArea.Value] = {
	Value.BASE: GuideArea.Value.BASE, Value.MAP: GuideArea.Value.MAP,
	Value.ARMY: GuideArea.Value.ARMY, Value.TECH: GuideArea.Value.RESEARCH,
}


## The name of [param tab] in the language on: "Base", "Carte"...
static func label(tab: Value) -> String:
	return Texts.t(KEYS[tab])


## The file of the glyph of [param tab].
static func icon_path(tab: Value) -> String:
	return UiIcon.glyph_path(ICONS[tab])
