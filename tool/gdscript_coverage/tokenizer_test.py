import unittest

from gdscript_coverage.tokenizer import tokenize


def starts(source):
    """(line, indent, first token) of each statement."""
    return [(s.line, s.indent, s.tokens[0].text) for s in tokenize(source)]


class TokenizerTest(unittest.TestCase):
    def test_a_statement_per_line_skipping_blanks_and_comments(self):
        source = "extends Node\n\n# note\nfunc f() -> void:\n\tpass  # done\n"
        self.assertEqual(
            starts(source), [(1, 0, "extends"), (4, 0, "func"), (5, 1, "pass")])

    def test_brackets_and_backslashes_continue_a_statement(self):
        source = "var a := [\n\t1, (2 +\n3),\n]\nvar b := 1 + \\\n\t2\nvar c\n"
        self.assertEqual(starts(source), [(1, 0, "var"), (5, 0, "var"), (7, 0, "var")])

    def test_every_string_form_hides_its_brackets_quotes_and_comments(self):
        forms = ['"(#\\""', "'(#\\''", '&"(#"', '^"(#"', 'r"(\\"#"', "r'(#'",
                 '"""(\n#"\n"""', "'''(\n'\n'''", 'r"""(\n"""', '"a\\\n("']
        for form in forms:
            with self.subTest(form=form):
                source = "var a := %s\nvar b\n" % form
                last = source.count("\n")
                self.assertEqual(starts(source), [(1, 0, "var"), (last, 0, "var")])
                self.assertEqual(tokenize(source)[0].tokens[-1].kind, "string")

    def test_r_inside_a_name_is_not_a_raw_prefix(self):
        tokens = tokenize('var bar = for_r\n')[0].tokens
        self.assertEqual([t.text for t in tokens], ["var", "bar", "=", "for_r"])

    def test_tokens_know_their_place_and_bracket_depth(self):
        tokens = tokenize("\tf(a: 1) -> x\n")[0].tokens
        self.assertEqual(
            [(t.text, t.line, t.col, t.depth) for t in tokens],
            [("f", 1, 1, 0), ("(", 1, 2, 0), ("a", 1, 3, 1), (":", 1, 4, 1),
             ("1", 1, 6, 1), (")", 1, 7, 0), ("->", 1, 9, 0), ("x", 1, 12, 0)])

    def test_marks_the_colon_ending_a_function_header(self):
        source = "func f(a := {1: 2}) -> Dictionary[int, int]: return {}\n"
        marked = [t.col for t in tokenize(source)[0].tokens if t.ends_header]
        self.assertEqual(marked, [source.index("]:") + 1])

    def test_a_statement_level_lambda_opens_a_function(self):
        statements = tokenize("var f := func(x):\n\treturn x\n")
        self.assertTrue(statements[0].opens_function)
        self.assertEqual(starts("var f := func(x):\n\treturn x\n"),
                         [(1, 0, "var"), (2, 1, "return")])

    def test_a_lambda_body_inside_brackets_is_made_of_statements(self):
        source = ("\ta.sort(func(x, y):\n\t\tif x:\n\t\t\treturn (x <\n\t\t\t\ty)\n"
                  "\t\treturn false\n\t)\n\tb()\n")
        statements = tokenize(source)
        self.assertTrue(statements[0].opens_function)
        self.assertEqual(starts(source), [
            (1, 1, "a"), (2, 2, "if"), (3, 3, "return"), (5, 2, "return"), (7, 1, "b")])
        self.assertEqual(statements[0].tokens[-1].text, ")")

    def test_a_lambda_body_may_end_with_the_closing_bracket(self):
        source = "\tf(func():\n\t\treturn 1)\n\tg(func(): return 2, func():\n\t\tpass\n\t, 3)\n\th()\n"
        self.assertEqual(starts(source), [
            (1, 1, "f"), (2, 2, "return"), (3, 1, "g"), (4, 2, "pass"), (6, 1, "h")])

    def test_windows_line_endings(self):
        self.assertEqual(starts("func f():\r\n\tpass\r\n"), [(1, 0, "func"), (2, 1, "pass")])


if __name__ == "__main__":
    unittest.main()
