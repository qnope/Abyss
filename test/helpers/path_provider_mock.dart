import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('plugins.flutter.io/path_provider');

/// Makes `getApplicationDocumentsDirectory` (used by `Hive.initFlutter`)
/// resolve to [path] for the rest of the test file.
void mockDocumentsDirectory(String path) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, (MethodCall call) async => path);
}

/// Removes the handler installed by [mockDocumentsDirectory].
void clearDocumentsDirectoryMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_channel, null);
}
