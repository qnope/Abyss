class_name IcuFormat
extends RefCounted
## Writes the ICU messages of the ARB files, the way Flutter's gen_l10n code
## does: `{name}` is replaced by the argument, `{n, plural, =0{..} one{..}
## other{..}}` by the branch of the count and `{k, select, a{..} other{..}}`
## by the branch of the text, a branch holding arguments of its own.
##
## A plural tries the exact `=N` case first, then `zero` for a count of 0,
## then the category of PluralRules, then `other`; a select tries its value,
## then `other`. The messages are checked when the .po files are written
## (tool/arb_to_po.py), so a malformed one only logs an error. Apostrophes
## are plain text, as in Flutter's default.
##
##     IcuFormat.format("{n, plural, one{{n} chat} other{{n} chats}}", {"n": 2}, "fr")


## `message` with its arguments (`args`, name to int or String) written for
## `locale`. An argument that is missing logs an error and writes nothing.
static func format(message: String, args: Dictionary, locale: String) -> String:
	var out := ""
	var at := 0
	while at < message.length():
		var open := message.find("{", at)
		if open < 0:
			return out + message.substr(at)
		out += message.substr(at, open - at)
		var close := _closing(message, open)
		if close < 0:
			push_error("IcuFormat: unclosed { in \"%s\"" % message)
			return out + message.substr(open)
		out += _argument(message.substr(open + 1, close - open - 1), args, locale)
		at = close + 1
	return out


## The text of the argument `body` ("n" or "n, plural, one{..} other{..}").
static func _argument(body: String, args: Dictionary, locale: String) -> String:
	var name := body.get_slice(",", 0).strip_edges()
	if not args.has(name):
		push_error("IcuFormat: no argument \"%s\"" % name)
	var value: Variant = args.get(name, "")
	if not body.contains(","):
		return _text(value)
	var kind := body.get_slice(",", 1).strip_edges()
	var branches := _branches(body.substr(body.find(",", body.find(",") + 1) + 1))
	var chosen := _select(value, branches) if kind == "select" \
		else _plural(_count(value), branches, locale)
	return format(chosen, args, locale)


static func _plural(count: int, branches: Dictionary[String, String], locale: String) -> String:
	var selectors: Array[String] = ["=%d" % count]
	if count == 0:
		selectors.append("zero")
	selectors.append(PluralRules.category(locale, count))
	for selector: String in selectors:
		if branches.has(selector):
			return branches[selector]
	return branches.get("other", "")


static func _select(value: Variant, branches: Dictionary[String, String]) -> String:
	return branches.get(_text(value), branches.get("other", ""))


## The branches of "one{..} other{..}": selector to the text in its braces.
static func _branches(text: String) -> Dictionary[String, String]:
	var found: Dictionary[String, String] = {}
	var at := 0
	while text.find("{", at) >= 0:
		var open := text.find("{", at)
		var close := _closing(text, open)
		found[text.substr(at, open - at).strip_edges()] = text.substr(open + 1, close - open - 1)
		at = close + 1
	return found


## The index of the `}` closing the `{` at `open`, or -1.
static func _closing(text: String, open: int) -> int:
	var depth := 0
	for index: int in range(open, text.length()):
		depth += 1 if text[index] == "{" else (-1 if text[index] == "}" else 0)
		if depth == 0:
			return index
	return -1


## The count of a plural argument: an int, or a float JSON handed over;
## 0 for anything else.
static func _count(value: Variant) -> int:
	var number: float = value if value is int or value is float else 0.0
	return int(number)


## A whole float, as JSON hands an int over, reads as that int.
static func _text(value: Variant) -> String:
	var number: float = value if value is float else 0.5
	return str(int(number)) if value is float and fposmod(number, 1.0) == 0.0 else str(value)
