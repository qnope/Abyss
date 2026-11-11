# presentation/ui/history

The log of the player (lib/presentation/widgets/history/): a bottom sheet, 80%
high, listing what the player did, newest first, filtered by category.

    HistorySheet(entries, modals, reports)
      -> HistoryFilterChips (changed) -> the cards of that category
      -> a touch on a tappable HistoryEntryCard -> HistoryReports.page_for(entry)
         -> the report page, opened on the modals over the sheet

## Parts

- `HistoryFilter`: the six filters (all, combat, construction, research,
  events, other), their labels and which entries each keeps.
- `HistoryFilterChips`: the row of chips (a `ChipRow`), `changed(filter)`.
- `HistoryEntryDisplay`: what an entry looks like (its accent colour from
  `theme/HistoryColors`, its picture, whether a touch does something).
- `HistoryEntryCard`: a card tinted with the entry's colour: a picture, the
  title (`texts/HistoryEntryTexts`), the turn. A tappable one has a chevron and
  carries the turn in its subtitle.
- `HistorySheet`: the sheet; reopening it starts again on "all". Pulling the
  handle down closes it.
- `HistoryReports`: the report page of an entry, rebuilt from what it stored:
  a combat reopens its `FightSummaryPage` (`ui/fight/`), a raid or a school of
  predators its `RaidReportPage` and a kraken wave its `VolcanoReportPage`
  (`ui/threat/`); a base assault its `BaseAssaultSummaryPage`
  (`ui/assault/`), read from the side of the player whose history it is: the
  attacker's own fight, or the defender's, whose victory is the repelled
  attack.

## Not reopened

A capture (`CaptureEntry`) is tappable but has no report behind it, in Flutter
too: `HistoryReports.page_for` gives null and a touch does nothing. The history
opens from the settings dialog (`ui/settings/`).
