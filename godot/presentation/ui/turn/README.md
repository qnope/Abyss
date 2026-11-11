# presentation/ui/turn

The end of a turn, from the "next turn" press to the next playable state
(lib/presentation/widgets/turn/ and screens/game/game_screen_end_turn.dart).

    EndTurnFlow.request() -> TurnConfirmation -> confirmed
      -> GameActions.end_turn() (saved by `acted`, redrawn by `changed`)
      -> turn_ended -> TurnOutcome: the pages, one after the other
      -> finished, or defeated when the turn lost the game

Cancelling, or dismissing the question, leaves the turn where it is. The flow
is a chain of signals, no `await`. It saves and navigates nothing: `app/` joins
`finished` and `defeated` to the screens (`app/README.md`).

## Parts

- `TurnForecast`: what the turn will do, read from the domain before it runs
  (production, buildings the lack of energy shuts down, units the lack of
  algae takes, scouts still out). Like Flutter's, the production announced is
  the one before the shutdowns.
- `TurnConfirmation`: the question, with the forecast and the warnings. Only the
  "no production" line shows when there is nothing to tell.
- `TurnSummary`: the dialog of what the turn did, one section per line of
  `SummarySections.of(result)`.
- `TurnOutcome`: the ordered queue of pages shown after a turn
  (`default_steps(actions)`: the summary, then the card of the event drawn,
  `EventStep`).
- Components: `SummaryLine`, `ResourceChangeLine`, `LossSection` (built by
  `TurnLosses`, `UndefendedPostWarning` by `TurnWarnings`). Factories are in
  `RefCounted` classes, not static functions of the nodes: a node class that
  builds itself in a static function leaks its script (Godot 4.7).

## Extension points, and what is still to come

A lot that owns a part of the turn adds to one of three places, and nothing else
changes.

- `SummarySections.of(result)`: a section of the summary is a `Control` added
  at the place Flutter puts it, after the losses: the raid and the kraken wave
  (`ThreatSections`), the attacks of the factions between them
  (`../faction/AttackSections`), then the event lines (`EventTurnSection`). To
  come: the exploration summary (lot 9) before the raid, the objectives
  completed (lot 15) after them.
- `TurnWarnings.of(game, player)`: a warning of the question. The threats
  (`ThreatWarnings`: the raid, the predators, the guardians of a Faille, the
  kraken wave) come first, then the undefended posts, then the event waiting
  for a choice (`EventPendingWarning`).
- `TurnOutcome.default_steps(actions)`: a step is a `Callable` returning the
  next page (a `Control` with a `closed` signal) or null when it has nothing to
  show; a page that changes the game (the event's choice) is built with the
  `actions`. After `summary_page` come the reports of the raid, of the
  predators and of a kraken wave lost (`ThreatPages`), then the event card
  (`EventStep`). To come, in Flutter's order: the objective and tip cards
  (lot 15). The turn's stories (animations) are step 7's.

Shown: resources, shutdowns, lost units, the recruitment now open and the
events. Not shown yet: everything else above.
