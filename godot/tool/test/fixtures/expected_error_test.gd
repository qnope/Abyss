extends TestCase
## A fixture whose tests log errors: the one that expects its error passes,
## the two others fail.


func test_expects_the_error_it_logs() -> void:
	expect_error("on purpose")
	push_error("broken on purpose")


func test_expects_an_error_that_never_comes() -> void:
	expect_error("never logged")


func test_logs_more_than_it_expects() -> void:
	expect_error("first")
	push_error("first error")
	push_error("second error")
