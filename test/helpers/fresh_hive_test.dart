import 'dart:io';

import 'package:abyss/hive_registrar.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'fresh_hive.dart';

void main() {
  late Directory dir;

  setUpAll(resetHive);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('abyss_fresh_hive_');
    Hive.init(dir.path);
  });
  tearDown(() async {
    await resetHive();
    dir.deleteSync(recursive: true);
  });

  test('lets the app register its adapters again', () async {
    Hive.registerAdapters();
    expect(Hive.isAdapterRegistered(58), isTrue);

    await resetHive();

    expect(Hive.isAdapterRegistered(58), isFalse);
    expect(Hive.registerAdapters, returnsNormally);
  });

  test('keeps the adapters Hive registers for itself', () async {
    await resetHive();
    Hive.init(dir.path);
    final box = await Hive.openBox<Object>('values');
    final at = DateTime.utc(2026, 10, 31, 12);
    await box.put('at', at);
    await box.put('big', BigInt.two.pow(80));
    await box.put('wait', const Duration(minutes: 3));
    await box.close();

    final again = await Hive.openBox<Object>('values');
    expect(again.get('at'), at);
    expect(again.get('big'), BigInt.two.pow(80));
    expect(again.get('wait'), const Duration(minutes: 3));
  });

  test('closes the boxes left open', () async {
    await Hive.openBox<int>('left');

    await resetHive();

    expect(Hive.isBoxOpen('left'), isFalse);
  });
}
