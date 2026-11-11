class_name CollectMessages
extends RefCounted
## What the dialog that tells a search found says (lib/presentation/screens/
## game/game_screen_collect_messages.dart), by what was searched.

const _TITLES: Dictionary[CellContentType.Value, StringName] = {
	CellContentType.Value.RESOURCE_BONUS: &"screenTreasureCollected",
	CellContentType.Value.RUINS: &"screenRuinsSearched",
	CellContentType.Value.WRECK: &"screenWreckSearched",
}
const _EMPTY: Dictionary[CellContentType.Value, StringName] = {
	CellContentType.Value.RUINS: &"screenRuinsEmpty",
	CellContentType.Value.WRECK: &"screenWreckEmpty",
}


## The title of the dialog telling what a search of [param content] found.
static func title_for(content: CellContentType.Value) -> String:
	var key: StringName = _TITLES.get(content, &"screenCollectTitle")
	return Texts.t(key)


## What the dialog says when a search of [param content] found nothing.
static func empty_message_for(content: CellContentType.Value) -> String:
	var key: StringName = _EMPTY.get(content, &"screenNothingToCollect")
	return Texts.t(key)
