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
- `HistoryReports`: the hook that gives the report page of an entry.

## Deferred

`HistoryReports.page_for` returns null for every entry: the pages it must open
belong to other lots. The branch of each is listed in the class: the fight
summary (the combat entries), the raid and kraken reports (the threats), the
assault summary (the base assaults). A touch on a card without a page does
nothing. Flutter opens the history from the settings dialog; here it is the
same link (`ui/settings/`).
