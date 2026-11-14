# presentation/ui/event

The random events (lib/presentation/widgets/event/, and
screens/game/game_screen_event_actions.dart): the card that announces one, the
strip that reminds of it, the warning before the end of a turn and the lines of
the summary.

    end of turn -> TurnOutcome: summary -> EventStep -> EventCard
      -> a choice -> GameActions.execute(ChooseEventAction) -> acted
         -> changed (the screen redrawn; app/game/GameSession saves the game)
      -> "later" -> the event stays pending
    status bar (EventStatusBar) -> a touch on the pending line -> EventCard

## Parts

- `EventCardTexts`, `EventCardData`, `EventChoice`: what a card says and offers,
  with the figures of `EventRules` and of the offer drawn (the survivors, the
  trade, the predators' wave). A first option the stock forbids carries its
  `refusal`.
- `EventCard`: an `IllustratedCard` (the event's picture, its name, two lines,
  then the options stacked). The first option is filled, the prudent one
  outlined, "later" a text button; an event that only informs (the storm, the
  wreck) offers "Got it". A choice goes through the `GameActions`: a success ends
  the card with `true` (first option) or `false` (prudent), "later" and "got it"
  with null.
- `EventStatusBar`: a `RefreshingPanel` for the strip under the raid and volcano
  bars, added to `GameStatusBars` by `GameHud`: the pending event (a touch opens
  its card on the modals), the effect that lasts and the wreck on the map, as
  `StripLine`s. Hidden when there is none.
- `EventPendingWarning`: the line `TurnWarnings` adds to the question before a
  turn ends while an event waits.
- `EventTurnSection`: the lines `SummarySections` adds to the summary (the
  predators fought, the event settled by default, the event drawn).
- `EventStep`: the `TurnOutcome` step that shows the card of the event the turn
  drew, not for a game the turn lost.

## Not one to one

- A refused choice (made after its turn) is told in the card, which stays open;
  Flutter closes the card and tells it in a snack bar. The snack bar that
  confirms a choice ("Survivants : Accueillir 4 harponneurs") is not ported: the
  UI kit has no snack bar yet. The strip, the resources and the history say it.
- The illustration is the event's SVG, an interface icon.
