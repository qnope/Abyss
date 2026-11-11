"""Tests of arb_to_po.py and icu_message.py: python3 -m unittest discover -s tool -p '*_test.py'"""

import json
import os
import tempfile
import unittest

import arb_to_po
import icu_message


class ParseTest(unittest.TestCase):
    def test_reads_text_and_arguments(self):
        self.assertEqual(
            icu_message.parse("Tour {turn} sur {max}"),
            [("text", "Tour "), ("arg", "turn"), ("text", " sur "), ("arg", "max")],
        )

    def test_reads_a_plural_with_its_selectors_in_order(self):
        node = icu_message.parse("{n, plural, =0{aucun} one{{n} cas} other{{n} cas}}")[0]
        self.assertEqual(node[:2], ("plural", "n"))
        self.assertEqual(list(node[2]), ["=0", "one", "other"])
        self.assertEqual(node[2]["one"], [("arg", "n"), ("text", " cas")])

    def test_reads_a_select_and_a_nested_argument(self):
        node = icu_message.parse("{k, select, a{x {n, plural, one{1} other{many}}} other{y}}")[0]
        self.assertEqual(node[:2], ("select", "k"))
        self.assertEqual(node[2]["a"][1][:2], ("plural", "n"))

    def test_keeps_apostrophes_and_unicode_literal(self):
        self.assertEqual(icu_message.parse("l'Amiral d’en bas"), [("text", "l'Amiral d’en bas")])

    def test_collects_every_argument_name_nested_ones_too(self):
        nodes = icu_message.parse("{a, select, x{{b}} other{{c, plural, one{{c}} other{d}}}}")
        self.assertEqual(icu_message.arguments(nodes), {"a", "b", "c"})

    def test_fails_on_unbalanced_braces(self):
        for text in ("{a", "a}", "{a, plural, one{x}", "{}"):
            with self.assertRaises(icu_message.IcuError, msg=text):
                icu_message.parse(text)

    def test_fails_on_an_unknown_type_or_a_branch_missing_other(self):
        with self.assertRaisesRegex(icu_message.IcuError, "selectordinal"):
            icu_message.parse("{n, selectordinal, other{x}}")
        with self.assertRaisesRegex(icu_message.IcuError, "other"):
            icu_message.parse("{n, plural, one{x}}")

    def test_fails_on_a_plural_category_it_does_not_support(self):
        with self.assertRaisesRegex(icu_message.IcuError, "many"):
            icu_message.parse("{n, plural, many{x} other{y}}")
        with self.assertRaisesRegex(icu_message.IcuError, "=x"):
            icu_message.parse("{n, plural, =x{x} other{y}}")

    def test_fails_on_a_duplicate_selector_or_a_missing_one(self):
        with self.assertRaisesRegex(icu_message.IcuError, "twice"):
            icu_message.parse("{n, select, a{x} a{y} other{z}}")
        with self.assertRaisesRegex(icu_message.IcuError, "selector"):
            icu_message.parse("{n, select, {x} other{z}}")


class EscapeTest(unittest.TestCase):
    def test_escapes_what_a_po_string_needs(self):
        self.assertEqual(arb_to_po.escape('a "b" \\ c\nd\te'), 'a \\"b\\" \\\\ c\\nd\\te')

    def test_leaves_unicode_and_braces(self):
        self.assertEqual(arb_to_po.escape("é {x} –"), "é {x} –")


def write_arbs(folder, texts):
    for language, messages in texts.items():
        data = {"@@locale": language}
        data.update(messages)
        path = os.path.join(folder, f"app_{language}.arb")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)


GOOD = {
    "fr": {"hello": "Salut {name}", "n": "{c, plural, one{{c} chat} other{{c} chats}}"},
    "en": {"hello": "Hi {name}", "n": "{c, plural, one{{c} cat} other{{c} cats}}"},
    "es": {"hello": "Hola {name}", "n": "{c, plural, one{{c} gato} other{{c} gatos}}"},
}


def changed(**edits):
    """GOOD with `language/key` set to a text."""
    texts = {language: dict(messages) for language, messages in GOOD.items()}
    for path, text in edits.items():
        language, key = path.split("__")
        texts[language][key] = text
    return texts


class LoadTest(unittest.TestCase):
    def load(self, texts):
        with tempfile.TemporaryDirectory() as folder:
            write_arbs(folder, texts)
            return arb_to_po.load(folder, tuple(texts))

    def test_loads_the_keys_in_the_order_of_the_first_language(self):
        messages = self.load(GOOD)
        self.assertEqual(list(messages["fr"]), ["hello", "n"])
        self.assertEqual(messages["en"]["hello"], "Hi {name}")

    def test_skips_the_metadata(self):
        meta = {"@hello": {"placeholders": {"name": {"type": "String"}}}}
        texts = {k: dict(v, **meta) for k, v in GOOD.items()}
        self.assertEqual(list(self.load(texts)["fr"]), ["hello", "n"])

    def test_fails_when_a_language_misses_a_key(self):
        texts = changed()
        del texts["es"]["n"]
        with self.assertRaisesRegex(ValueError, r"es.*missing.*n"):
            self.load(texts)

    def test_fails_when_a_language_has_an_extra_key(self):
        with self.assertRaisesRegex(ValueError, r"en.*extra"):
            self.load(changed(en__extra="x"))

    def test_fails_when_the_placeholders_differ(self):
        with self.assertRaisesRegex(ValueError, r"hello.*en"):
            self.load(changed(en__hello="Hi {who}"))

    def test_fails_naming_the_key_and_language_of_a_bad_message(self):
        with self.assertRaisesRegex(ValueError, r"es.*hello"):
            self.load(changed(es__hello="Hola {name"))

    def test_fails_when_a_placeholder_is_not_in_the_metadata(self):
        meta = {"@hello": {"placeholders": {"who": {"type": "String"}}}}
        texts = {k: dict(v, **meta) for k, v in GOOD.items()}
        with self.assertRaisesRegex(ValueError, r"hello.*placeholders"):
            self.load(texts)


class RenderTest(unittest.TestCase):
    def test_writes_a_header_and_one_entry_per_key(self):
        text = arb_to_po.render("fr", {"a": 'Un "x"', "b": "{n} é"})
        self.assertIn('"Language: fr\\n"', text)
        self.assertIn('"Content-Type: text/plain; charset=UTF-8\\n"', text)
        self.assertIn('msgid "a"\nmsgstr "Un \\"x\\""\n', text)
        self.assertLess(text.index('msgid "a"'), text.index('msgid "b"'))
        self.assertTrue(text.endswith('msgstr "{n} é"\n'))


class MainTest(unittest.TestCase):
    def run_main(self, folders, *flags):
        arb, out = folders
        return arb_to_po.main([*flags, "--arb-dir", arb, "--out-dir", out])

    def folders(self, root, texts=GOOD):
        arb, out = os.path.join(root, "arb"), os.path.join(root, "po")
        os.makedirs(arb)
        os.makedirs(out)
        write_arbs(arb, texts)
        return arb, out

    def test_writes_then_checks_clean(self):
        with tempfile.TemporaryDirectory() as root:
            folders = self.folders(root)
            self.assertEqual(self.run_main(folders), 0)
            self.assertEqual(sorted(os.listdir(folders[1])), ["en.po", "es.po", "fr.po"])
            self.assertEqual(self.run_main(folders, "--check"), 0)

    def test_check_fails_on_a_stale_or_missing_file_and_writes_nothing(self):
        with tempfile.TemporaryDirectory() as root:
            folders = self.folders(root)
            self.assertEqual(self.run_main(folders, "--check"), 1)
            self.assertEqual(os.listdir(folders[1]), [])
            self.run_main(folders)
            with open(os.path.join(folders[1], "fr.po"), "a", encoding="utf-8") as f:
                f.write("# edited\n")
            self.assertEqual(self.run_main(folders, "--check"), 1)

    def test_a_bad_arb_fails_without_writing(self):
        with tempfile.TemporaryDirectory() as root:
            texts = changed()
            del texts["en"]["n"]
            folders = self.folders(root, texts)
            self.assertEqual(self.run_main(folders), 1)
            self.assertEqual(os.listdir(folders[1]), [])


class RepositoryTest(unittest.TestCase):
    def test_the_game_s_arb_files_are_valid(self):
        messages = arb_to_po.load(arb_to_po.ARB_DIR, arb_to_po.LANGUAGES)
        self.assertEqual(len(messages["fr"]), len(messages["en"]))
        self.assertGreater(len(messages["fr"]), 800)

    def test_the_committed_po_files_are_current(self):
        self.assertEqual(arb_to_po.main(["--check"]), 0)


if __name__ == "__main__":
    unittest.main()
