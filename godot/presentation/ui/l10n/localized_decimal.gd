class_name LocalizedDecimal
extends RefCounted
## lib/presentation/extensions/decimal_extensions.dart: a number with a
## fixed count of decimals in the player's language, "1,5" in French and
## Spanish and "1.5" in English, groups of thousands included ("1 234,5"
## with a narrow no-break space in French, "1.234,5" in Spanish, "1,234.5"
## in English). Like Flutter's NumberFormat, it rounds the number scaled to
## its decimals, half away from zero.

## Per language, the separator of the groups of thousands and the decimal one.
const _SEPARATORS := {
	"fr": [" ", ","],
	"es": [".", ","],
	"en": [",", "."],
}


## `value.decimal(l10n, digits: digits)` in `locale`.
static func format(value: float, locale: String, digits: int = 1) -> String:
	var separators: Array = _SEPARATORS.get(locale.left(2), _SEPARATORS["en"])
	var scaled := roundi(absf(value) * float(DartMath.int_pow(10, digits)))
	var text := str(scaled).lpad(digits + 1, "0")
	var whole := text.left(text.length() - digits)
	var grouped := ""
	for index: int in whole.length():
		if index > 0 and (whole.length() - index) % 3 == 0:
			grouped += str(separators[0])
		grouped += whole[index]
	var fraction := str(separators[1]) + text.right(digits) if digits > 0 else ""
	return ("-" if value < 0.0 else "") + grouped + fraction
