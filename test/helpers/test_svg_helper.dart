import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

const _minimalSvg =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1 1"></svg>';

void mockSvgAssets() {
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (message) async {
      final encoded = utf8.encode(_minimalSvg);
      return ByteData.view(Uint8List.fromList(encoded).buffer);
    },
  );
}

void clearSvgMocks() {
  final binding = TestDefaultBinaryMessengerBinding.instance;
  binding.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    null,
  );
}
