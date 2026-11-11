# presentation/ui/objective

The objectives (lib/presentation/widgets/objective/).

- `ObjectiveBanner`: the strip under the status bars: the flag (or the post to
  take), the chapter, the objective and its progress, the temporary objectives.
  Hidden once all are done. A touch opens the sheet.
- `ObjectivesSheet`: a bottom sheet of `ObjectiveSections.of(game)`: a header
  per chapter (`ObjectiveSectionHeader`, with its lore) and an `ObjectiveRow` per
  objective (done, current, to do or temporary: `ObjectiveStatus`), with its
  reward and progress. `ObjectivePosts` tells which post an objective asks for.

The objectives completed in a turn are told in the summary
(`../turn/ObjectiveTurnSection`). The texts are `../texts/ObjectiveTexts`,
`ChapterTexts` and `TemporaryObjectiveTexts`.
