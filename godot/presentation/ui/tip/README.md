# presentation/ui/tip

The « première fois » tips (lib/presentation/widgets/tip/): a short card the
first time a system shows up, then kept in the Guide.

- `TipCard`: one tip in an `IllustratedCard`: picture, title, lines, « Compris ».
- `TipStack`: the tips that arrive together, one card at a time, « Suivant » or a
  swipe to go on, « n / m », the last card closes it. The cards peeking out
  behind the front one in Flutter are not drawn.
- `TipGuide`: every tip by section; those seen open their card again, the others
  are greyed « ??? ». Opened from the guide settings (`../settings/GuideSettings`,
  « Revoir les fiches »). `TipGuideRow` is one line of it.
- `TipIllustrations`: the picture of a tip; a `Portrait` for a building, unit,
  monster (the render of its model) or post, chest and ruins (initials, no model
  render yet), an icon for an event, a faction or the guide.
- `TipPresenter`: the stack of the tips waiting (`TipCatalog.pending_for`), marked
  seen with one `GameActions.mark_tips_seen` (one save) before it shows; null
  when tips are off, none waits, or the game is over. Its `step()` ends the pages
  of a turn (`../turn/TurnOutcome`); `app/game/TipWatcher` opens the stack after
  any other action, when no modal covers the screen.

What is seen is the player's `ObjectiveState`, saved with the game: no save
format of its own.
