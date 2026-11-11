# presentation/ui/guide

The tutorial's guide on the interface (lib/presentation/widgets/guide/): what it
says in a bubble, and the halos around what it points at. Nothing here knows
the guide's advice: `GuideAdvisor` (domain) chooses it, `GuideScope` carries it.

- `GuideScope`: the advice of the human player, read again on `refresh()`, which
  `GameActions` calls on every `acted` before the session saves and redraws.
  `changed` tells whoever follows; `points(picks)` asks whether a Callable
  recognises the target. Flutter's inherited widget, as a plain object handed
  to the components that may carry a halo (`GameActions.guide`).
- `GuidedHalo`: a `common/GuideHalo` that lights while the scope's target is
  what its `picks` Callable recognises, and follows `changed`. `GuideCardHalo`
  takes the radius of a card. Wrapped around the tabs (`game/GameTabBar`), the
  turn button (`game/TurnBar`), the level chips (`map/LevelSelector`) and the
  medallions and nodes of the research (`tech/`).
- `GuideBubble`: the octopus archivist's portrait, the words of the advice and
  « Compris » at the bottom of the screen. « Compris » hides it, the halo stays;
  a new message shows it again (for a post to find, a new turn does).

The halo of a building, a unit or a cell of the map is not here: it lies on the
floor of the world (`../../world/guide/`), aimed by `app/game/GuideController`.
