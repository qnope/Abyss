import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';

const _boxName = 'building_type_test';

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(BuildingTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(BuildingAdapter());
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BuildingType', () {
    test('headquarters exists', () {
      expect(BuildingType.headquarters, isNotNull);
    });

    test('enum has exactly 10 values', () {
      expect(BuildingType.values.length, 10);
    });

    test('laboratory exists', () {
      expect(BuildingType.laboratory, isNotNull);
    });

    test('barracks exists', () {
      expect(BuildingType.barracks, isNotNull);
    });

    test('coralCitadel exists', () {
      expect(BuildingType.coralCitadel, isNotNull);
    });
  });

  group('BuildingType Hive round-trip', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('abyss_bt_test_');
      Hive.init(tempDir.path);
      _registerAdapters();
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk(_boxName);
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('coralCitadel Building survives a Hive round-trip', () async {
      final box = await Hive.openBox<Building>(_boxName);
      await box.put(
        'citadel',
        Building(type: BuildingType.coralCitadel, level: 3),
      );
      await box.close();

      final reopened = await Hive.openBox<Building>(_boxName);
      final loaded = reopened.get('citadel');

      expect(loaded, isNotNull);
      expect(loaded!.type, BuildingType.coralCitadel);
      expect(loaded.level, 3);
    });
  });
}
