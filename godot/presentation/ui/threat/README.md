# presentation/ui/threat

What the player sees of the three threats: the raid on the base, the guardians
that come back to the Faille (the "Leviathan") and the kraken waves on the
kernel. Ported from `lib/presentation/widgets/{raid,volcano,leviathan}/` and
`screens/game/{raid,volcano}/`. Everything is read from the domain `Game` and
`TurnResult`: no rule lives here. Depends on `domain/`, `../theme`, `../l10n`,
`../texts`, `../common`, `../fight`, `../turn` (`SummaryLine`) and `../game`
(`GameStatusBars`) only.

    status strips   ThreatBars.add_to(status_bars, game)  -> GameHud
    the question    ThreatWarnings.of(game, player)       -> TurnWarnings.of
    the summary     ThreatSections.raid / .volcano(result) -> SummarySections.of
    the reports     ThreatPages.raid / .predators / .volcano -> TurnOutcome.default_steps

## Status strips (under the resource bar)

`ThreatStrip` is the strip on surface dim that hides itself when it has nothing
to tell, so that the stack closes up. In Flutter's order:

- `RaidStatusBar`: the noise gauge (`NoiseGauge`, the warning variation of the
  theme's `ProgressBar`) and `n/40`, or in its place the alert of the raid on
  its way (this turn, or on turn N) with the weakness of its families in green;
  the raids lost in a row (`n/3`) under either.
- `LeviathanStatusBar`: the red `ThreatBanner` of the turn the guardians strike,
  the force and the units of the level that defends the Faille. `opened` tells
  the Faille to open on when a touch is wanted (`tappable`, off until the map
  lot wires it).
- `VolcanoStatusBar`: the wave due at the end of the turn against the kernel's
  garrison, red when nobody guards the kernel.

## Warnings of the question (`DueWarning`: a separator and a red line)

`RaidDueWarning` (also for the school of predators, and the "if this raid is
lost the game is over" reminder), `LeviathanDueWarning` (level empty or too weak
for `LeviathanDefenceAdvisor`), `VolcanoDueWarning` (a wave on an empty
garrison). `ThreatWarnings.of` lists them in Flutter's order: raid, predators,
guardians, wave. `ThreatDefenders` counts the units that stand where a threat
strikes.

## Summary sections and reports

`RaidTurnSection` and `VolcanoTurnSection` are the lines of the summary (fought,
announced). After it, `TurnOutcome` opens the reports as pages (a
`ThreatReportPage`: a `FullPage` with the cards of the report and "back to the
base"): `RaidReportPage` (also the predators' report), then `VolcanoReportPage`
for a wave that was lost; a wave repelled stays a line of the summary.
`RaidPillageCard` and `ThreatInfoCard` (the rampart / kernel card) are theirs.
`NoiseCostRow` ("+N bruit") is shown under an action's cost.

## Not ported

- The turn's story told on the map (step 7) and the fight in 3D.
- The guardians' attack report and the factions' attacks: lot 13 (they come
  from `TurnResult.attacks` and `leviathan`).
- The kernel's garrison panel: lot 12.

The tests are in `tests/`, on `UiTestCase`, from real fights
(`ThreatSamples`).
