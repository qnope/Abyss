class_name Sha256Hex
extends RefCounted
## tool/reference/sha256_hex.dart: the digest of the reference games, the
## SHA-256 of the UTF-8 bytes of a text in lowercase hexadecimal. The
## domain only writes the texts (GameSnapshot.digests takes this function),
## as the Dart domain leaves the `crypto` package to its tools.


static func of(text: String) -> String:
	return text.sha256_text()
