import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../presentation/widgets/guide/guide_widget_helpers.dart';

/// The army of a player shown alone, with what its touches opened.
class ArmyViewHarness {
  final nemo = Player(name: 'Nemo');

  /// The units opened by a touch, and the barracks.
  final tapped = <UnitType>[];
  final opened = <Building>[];

  /// Shows the army of [counts] units at [place], [recruitable] ones, a
  /// barracks at [barracks] and a citadel at [citadel], its figures
  /// loaded, pumped up to [phase].
  Future<void> show(
    WidgetTester tester, {
    int barracks = 3,
    int citadel = 1,
    int? place,
    Map<UnitType, int> counts = const {},
    Set<UnitType> recruitable = const {},
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  }) async {
    await tester.runAsync(ArmySprites.load);
    nemo
      ..buildings[BuildingType.barracks]!.level = barracks
      ..buildings[BuildingType.coralCitadel]!.level = citadel;
    await tester.pumpWidget(
      guidedApp(
        ArmyView(
          buildings: nemo.buildings,
          counts: counts,
          place: place,
          recruitable: recruitable,
          onUnitTap: tapped.add,
          onBarracksTap: opened.add,
        ),
        null,
      ),
      phase: phase,
    );
    if (phase == EnginePhase.sendSemanticsUpdate) await tester.pump();
  }
}

/// The painter of type [T] of the only custom paint holding one.
T painterOf<T>(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<T>()
    .single;
