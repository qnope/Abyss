class_name ChapterTexts
extends RefCounted
## lib/presentation/extensions/objective_extensions.dart
## (ObjectiveChapterDisplay): the name of a chapter of the objectives, the line
## of lore told under it and its name after its number.


## `chapter.title(l10n)`: "Le récif".
static func title(chapter: ObjectiveChapter.Value) -> String:
	return Texts.t(TextKeys.of("chapter", ObjectiveChapter.Value, chapter))


## `chapter.lore(l10n)`: the line of lore told under the title.
static func lore(chapter: ObjectiveChapter.Value) -> String:
	return Texts.t(TextKeys.of("chapter", ObjectiveChapter.Value, chapter, "Lore"))


## `chapter.numberedTitle(l10n)`: "2. Le récif".
static func numbered_title(chapter: ObjectiveChapter.Value) -> String:
	return Texts.t(&"chapterNumbered", {"number": chapter + 1, "title": title(chapter)})
