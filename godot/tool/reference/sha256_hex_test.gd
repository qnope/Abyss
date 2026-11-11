extends TestCase
## test/tool/sha256_hex_test.dart.


func test_is_the_sha_256_of_the_utf_8_bytes_in_lowercase_hex() -> void:
	assert_eq(Sha256Hex.of(""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
	assert_eq(Sha256Hex.of("abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
	# "é" is two bytes in UTF-8 (c3 a9).
	assert_eq(Sha256Hex.of("é"), "4a99557e4033c3539de2eb65472017cad5f9557f7a0625a09f1c3f6e2ba69c4c")
