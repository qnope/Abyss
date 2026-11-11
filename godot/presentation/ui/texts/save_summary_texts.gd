class_name SaveSummaryTexts
extends RefCounted
## lib/presentation/extensions/save_summary_extensions.dart (SaveSummaryLabels):
## what a save card writes about a game, in the language on. The thumbnail of
## the depth is not here: a `Portrait` stands in for it.


## `summary.depthName(l10n)`: the deepest level reached, by name.
static func depth_name(summary: SaveSummary) -> String:
	return MapLevelTexts.name_of(summary.deepest_level)


## The difficulty of a game still played, or that it was won or lost. A game
## won then played on keeps its victory.
static func badge_label(summary: SaveSummary) -> String:
	match summary.outcome:
		SaveOutcome.Value.IN_PROGRESS:
			return DifficultyTexts.display_name(summary.difficulty).to_upper()
		SaveOutcome.Value.DEFEAT:
			return Texts.t(&"saveDefeatBadge")
	return Texts.t(&"saveVictoryBadge")


## The badge's tint: the difficulty's, gold for a win, red for a defeat.
static func badge_color(summary: SaveSummary) -> Color:
	match summary.outcome:
		SaveOutcome.Value.IN_PROGRESS:
			return DifficultyTexts.color(summary.difficulty)
		SaveOutcome.Value.DEFEAT:
			return AbyssColors.ERROR
	return AbyssColors.ENERGY_YELLOW


## "Tour 14 · Profondeurs · QG niv. 3". A finished game tells its difficulty
## instead, its badge telling how it ended.
static func meta_line(summary: SaveSummary) -> String:
	var depth := depth_name(summary)
	var difficulty := DifficultyTexts.display_name(summary.difficulty)
	match summary.outcome:
		SaveOutcome.Value.VICTORY:
			return Texts.t(&"saveMetaWon",
				{"turn": summary.turn, "depth": depth, "difficulty": difficulty})
		SaveOutcome.Value.DEFEAT:
			return Texts.t(&"saveMetaFallen",
				{"turn": summary.turn, "depth": depth, "difficulty": difficulty})
	return Texts.t(&"saveMetaInProgress",
		{"turn": summary.turn, "depth": depth, "level": summary.headquarters_level})


## The last line of a finished game, null for a game in progress, which
## lists its resources there instead.
static func footnote(summary: SaveSummary) -> Variant:
	match summary.outcome:
		SaveOutcome.Value.VICTORY:
			var kernel := &"saveKernelConquered" if summary.volcanic_kernel_captured else &"saveVictory"
			return Texts.t(kernel)
		SaveOutcome.Value.DEFEAT:
			return Texts.t(&"saveSeeReport")
	return null


## Which game a "continue" resumes: "Alice · Tour 14 · Normal".
static func resume_label(summary: SaveSummary) -> String:
	return Texts.t(&"saveResumeLabel", {
		"name": summary.player_name,
		"turn": summary.turn,
		"difficulty": DifficultyTexts.display_name(summary.difficulty),
	})
