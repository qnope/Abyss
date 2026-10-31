import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Channels tests mock and may leave mocked (see mockDocumentsDirectory
/// and the clipboard tests).
const mockedChannels = [
  'plugins.flutter.io/path_provider',
  'flutter/platform',
];

/// Takes off the mocks tests leave on the platform channels and answers
/// assets from the test bundle again, as the test binding does at start.
void resetPlatformChannels() {
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  for (final channel in mockedChannels) {
    messenger.setMockMessageHandler(channel, null);
  }
  final assets = _bundledAssets();
  messenger.setMockMessageHandler('flutter/assets', assets);
  messenger.setMockMethodCallHandler(
      SystemChannels.navigation, assets == null ? null : (_) async => null);
}

/// Answers an asset from the folder `flutter test` builds them in, as
/// the test binding does (see its `mockFlutterAssets`); none when the
/// test runs without that folder.
MessageHandler? _bundledAssets() {
  final folder = Platform.environment['UNIT_TEST_ASSETS'];
  if (folder == null) return null;
  final prefix = 'packages/${Platform.environment['APP_NAME']}/';
  return (message) {
    final key = utf8.decode(message!.buffer.asUint8List());
    var asset = File('$folder/$key');
    if (!asset.existsSync() && key.startsWith(prefix)) {
      asset = File('$folder/${key.substring(prefix.length)}');
    }
    if (!asset.existsSync()) return null;
    final bytes = Uint8List.fromList(asset.readAsBytesSync());
    return SynchronousFuture(bytes.buffer.asByteData());
  };
}
