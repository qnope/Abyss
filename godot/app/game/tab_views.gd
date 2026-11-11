class_name TabViews
extends RefCounted
## What the world shows behind each tab of the game screen: the base on the
## Base tab, the map of a level on the Map tab, the army's parade ground on the
## Army tab, and nothing on the Tech tab, which covers it with its page.


## The view of the world for [param tab].
static func of(tab: GameTab.Value) -> WorldHost.View:
	match tab:
		GameTab.Value.BASE:
			return WorldHost.View.BASE
		GameTab.Value.MAP:
			return WorldHost.View.MAP
		GameTab.Value.ARMY:
			return WorldHost.View.PARADE
	return WorldHost.View.NONE
