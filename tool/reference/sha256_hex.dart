import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The digest of the reference games: the SHA-256 of the UTF-8 bytes of
/// [text], in lowercase hexadecimal.
String sha256Hex(String text) => sha256.convert(utf8.encode(text)).toString();
