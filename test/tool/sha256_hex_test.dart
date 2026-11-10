import 'package:flutter_test/flutter_test.dart';

import '../../tool/reference/sha256_hex.dart';

void main() {
  test('is the SHA-256 of the UTF-8 bytes, in lowercase hex', () {
    expect(
      sha256Hex(''),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      sha256Hex('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
    // "é" is two bytes in UTF-8 (c3 a9).
    expect(
      sha256Hex('é'),
      '4a99557e4033c3539de2eb65472017cad5f9557f7a0625a09f1c3f6e2ba69c4c',
    );
  });
}
