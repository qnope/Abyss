class_name TextsTestCase
extends TestCase
## The base of the tests of texts: it gives the language back to French
## after each test, as the runner does after each file, and checks that a key
## is translated in the three languages.

const LANGUAGES: Array[String] = ["fr", "en", "es"]


func after_each() -> void:
	TranslationServer.set_locale("fr")


## Fails unless `key` has a translation in French, English and Spanish.
func assert_translated(key: StringName) -> void:
	for locale in LANGUAGES:
		assert_true(Texts.has(key, locale), "%s has no %s translation" % [key, locale])


## Every `values` of the enum a text class names, each by `key_of`, which
## builds the key of a value: every one is translated in the three languages.
func assert_every_value_translated(enumeration: Dictionary, key_of: Callable) -> void:
	assert_false(enumeration.is_empty())
	for value: int in enumeration.values():
		var key: String = key_of.call(value)
		assert_translated(StringName(key))
