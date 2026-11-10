class_name TipCatalog
extends RefCounted
## lib/domain/objective/tip/tip_catalog.dart: every « première fois » tip
## card, and the one to open next.


## `TipCatalog.all`, a static final list in Dart: every tip, in the order
## of TipId (the first to apply opens first), new tips at each call.
static func all() -> Array[Tip]:
	var tips := BaseTips.base_tips()
	tips.append_array(ThreatTips.threat_tips())
	tips.append_array(MapTips.map_tips())
	tips.append_array(PostTips.post_tips())
	tips.append_array(EventTips.all())
	tips.append_array(ArchiveTips.archive_tips())
	DartSort.sort(tips, func(a: Tip, b: Tip) -> int: return DartSort.compare_ints(a.id, b.id))
	return tips


## The tip of `id`. The catalog holds every id once, in the order of the
## enum (its test checks it): an id is its index, where Dart indexes the
## list in a map.
static func by_id(id: TipId.Value) -> Tip:
	return all()[id]


## Every tip `player` has not seen yet whose situation is there in `game`,
## in catalog order; empty when the tips are off or none applies. Only the
## unseen tips are checked.
static func pending_for(game: Game, player: Player) -> Array[Tip]:
	var state := ObjectiveMigration.state_of(game, player)
	var pending: Array[Tip] = []
	if not state.tips_enabled:
		return pending
	for tip: Tip in all():
		if not state.has_seen(tip.id) and tip.applies_to(game, player):
			pending.append(tip)
	return pending


## The first of the `pending_for` tips, null when there is none.
static func next_for(game: Game, player: Player) -> Tip:
	var pending := pending_for(game, player)
	return null if pending.is_empty() else pending[0]
