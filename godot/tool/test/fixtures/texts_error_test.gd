extends TestCase
## A fixture for the harness: one test asks Texts for a text that exists,
## one for a text that does not, which logs an error and fails the test.


func test_asks_for_a_key_that_exists() -> void:
	assert_eq(Texts.t(&"commonClose"), "Fermer")


func test_asks_for_a_key_that_does_not_exist() -> void:
	assert_eq(Texts.t(&"noSuchKey"), "noSuchKey")
