class_name TabViews
extends RefCounted
## What the world shows behind each tab of the game screen: the base on the
## Base tab, the army's parade ground on the Army tab, and nothing on the
## others, which cover it with their page.


## The view of the world for [param tab].
static func of(tab: GameTab.Value) -> WorldHost.View:
	match tab:
		GameTab.Value.BASE:
			return WorldHost.View.BASE
		GameTab.Value.ARMY:
			return WorldHost.View.PARADE
	return WorldHost.View.NONE
