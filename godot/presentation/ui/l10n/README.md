# presentation/ui/l10n

The game's texts in French, English and Spanish.

## The pipeline

The ARB files of `lib/presentation/l10n` (`app_fr.arb` is the template) stay
the source until the switch to Godot. `tool/arb_to_po.py` writes the
`fr.po`, `en.po` and `es.po` next to this file, never edited by hand:

    python3 tool/arb_to_po.py            # write the three files
    python3 tool/arb_to_po.py --check    # fail if they are stale (CI)

Each entry is `msgid` = the ARB key (`newGameFactionsCount`) and `msgstr` =
the ICU message **verbatim**. Plurals with `=0`/`=1` cases, selects and two
arguments in one message are not gettext's, so the game formats the ICU
text itself at run time. Before writing, the tool checks that the three
languages have the same keys, that every message parses (`tool/icu_message.py`:
`{x}`, `plural` with `=N`, `zero`, `one` and `other`, `select`, nested
arguments), that a key has the same arguments in every language and that they
are the ones its `@key` metadata declares. The `.po` files are registered in
`godot/project.godot` (`internationalization/locale/translations`), so the
headless import, the tests and the exports (web, Android, iOS) load them.

After a change of an ARB file: run the tool and commit the `.po`; CI's
Godot job runs `--check`. When Flutter's texts change, regenerate
`tests/expected_texts.json` too (below).

## At run time

| Class | Role |
| --- | --- |
| `Texts` | `Texts.t(&"unitScoutCount", {"count": 3})`: `tr` of the key, formatted. An unknown key or a missing argument logs an error (the test that renders it fails) |
| `IcuFormat` | the formatter: `{x}`, `plural` (an exact `=N` first, then `zero`, then the category, then `other`), `select`, branches holding arguments. Apostrophes are plain text, as in Flutter |
| `PluralRules` | fr: `one` for 0 and 1; en, es: `one` for 1; otherwise `other` |
| `TextKeys` | the key of an enum value's text, from its Dart name: `TextKeys.of("building", BuildingType.Value, type, "Name")` is `buildingAlgaeFarmName` |
| `LocalizedDecimal` | `decimal_extensions.dart`: `1,5` in French and Spanish, `1.5` in English, groups of thousands |
| `RelativeDate` | `relative_date_extensions.dart`: "il y a 5 min", "hier", "5 oct." (dates in milliseconds, the time zone's offset given) |

The texts that name a domain value are in `../texts/` (`BuildingTexts`,
`UnitTexts`...): one static class per Dart extension, each tested for a key
in all three languages.

`app/locale/app_locale.gd` chooses the language (the player's, else the
device's) and sets the `TranslationServer`; the UI only calls `Texts`. A
node that writes a text when it is built rewrites it on
`NOTIFICATION_TRANSLATION_CHANGED`, which the server sends to every node when
the language changes.

## The tests

`tests/expected_texts.json` holds what Flutter writes for the 262 messages
with arguments, in the three languages: the plural and select cases with the
counts 0, 1, 2, 5, 21 and 1000000, every select value and one that matches
none, the other arguments at 7 or `Zed`. `tests/expected_decimals.json` is
what `NumberFormat` writes for 24 numbers with 0 to 3 digits. Both were made
by a scratch Flutter test, not committed, that called the generated
`app_localizations_{fr,en,es}.dart` classes with the same arguments; it
read the cases written by a Python script from the ARB files and wrote the
JSON. To redo them after a change of the ARB files, write such a test again
(one closure per method of `AppLocalizations`) and run it with
`flutter test`. `texts_test.gd` fails on the first text that differs.
