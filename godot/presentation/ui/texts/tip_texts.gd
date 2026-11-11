class_name TipTexts
extends RefCounted
## lib/presentation/extensions/tip_texts.dart and the tip_*_texts.dart files
## beside it (TipIdText, TipCategoryLabel): what the card of a « première
## fois » tip says, in the player's language: a title, then two or three short
## lines, the figures from the rules. The ARB names them `tip<Name>Title` and
## `tip<Name>Line<N>`; the tip of a random event is titled after the event.

const Id := TipId.Value


## `category.label(l10n)`: the name of a section of the Guide.
static func category_label(category: TipCategory.Value) -> String:
	return Texts.t(TextKeys.of("tipCategory", TipCategory.Value, category))


## `id.title(l10n)`: shown on the card and in the Guide.
static func title(id: TipId.Value) -> String:
	var event: Variant = DartEnum.by_name(RandomEventType.Value, DartEnum.name_of(TipId.Value, id))
	if event != null:
		var type: RandomEventType.Value = event
		return RandomEventTexts.label(type)
	return Texts.t(TextKeys.of("tip", TipId.Value, id, "Title"))


## `id.lines(l10n)`: the lines of the card, as many as the ARB has.
static func lines(id: TipId.Value) -> PackedStringArray:
	var found := PackedStringArray()
	var locale := TranslationServer.get_locale()
	var number := 1
	while Texts.has(_line_key(id, number), locale):
		var key := _line_key(id, number)
		found.append(Texts.t(key, _args(key)))
		number += 1
	return found


static func _line_key(id: TipId.Value, number: int) -> StringName:
	return TextKeys.of("tip", TipId.Value, id, "Line%d" % number)


## The figures a line names, which the rules own.
static func _args(key: StringName) -> Dictionary:
	match key:
		&"tipNoiseGaugeLine2":
			return {"threshold": NoiseRules.THRESHOLD}
		&"tipWorksitesLine1":
			return {"level": WorksiteRules.EXTRA_SITE_AT_HQ[0]}
		&"tipWorksitesLine2":
			return {"level": WorksiteRules.EXTRA_SITE_AT_HQ[1]}
		&"tipRaidAnnouncedLine1":
			return {"turns": NoiseRules.WARNING_TURNS}
		&"tipLastChanceLine1":
			return {"count": DefeatChecker.LOST_RAIDS_LIMIT - 1}
		&"tipKernelGarrisonLine2":
			return {"level": KernelGarrison.VOLCANO_LEVEL}
		&"tipKernelGarrisonLine3":
			return {"action": Texts.t(&"volcanoGarrisonUnits")}
	return _event_args(key)


static func _event_args(key: StringName) -> Dictionary:
	match key:
		&"tipEventsLine1":
			return {"minGap": EventRules.MIN_GAP, "maxGap": EventRules.MAX_GAP}
		&"tipWarmCurrentLine1", &"tipColdCurrentLine1":
			return {"turns": EventRules.EFFECT_TURNS}
		&"tipWreckLine1":
			return {"turns": EventRules.WRECK_TURNS}
		&"tipWreckLine3":
			return {"noise": EventRules.WRECK_NOISE}
		&"tipStormLine1":
			return {"turns": EventRules.STORM_TURNS}
		&"tipStormLine2":
			return {"relief": EventRules.STORM_NOISE_RELIEF}
	return {}
