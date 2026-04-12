import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/building/building_detail_sheet.dart';

final defaultPlayer = Player(name: 'Tester');

Widget buildSheetApp({
  required Building building,
  Map<ResourceType, Resource>? resources,
  Map<BuildingType, Building>? allBuildings,
  bool isVolcanicKernelCaptured = false,
  VoidCallback? onUpgrade,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showBuildingDetailSheet(
            ctx,
            building: building,
            resources: resources ?? defaultPlayer.resources,
            allBuildings: allBuildings ?? {building.type: building},
            isVolcanicKernelCaptured: isVolcanicKernelCaptured,
            onUpgrade: onUpgrade ?? () {},
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> openSheet(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void useTallSurface(WidgetTester t) {
  t.view.physicalSize = const Size(800, 1200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(() => t.view.resetPhysicalSize());
  addTearDown(() => t.view.resetDevicePixelRatio());
}

Building hq([int level = 0]) =>
    Building(type: BuildingType.headquarters, level: level);
