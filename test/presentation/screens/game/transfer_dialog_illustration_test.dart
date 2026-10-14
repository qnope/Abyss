import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/descent_dialog.dart';
import 'package:abyss/presentation/screens/game/reinforcement_dialog.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';

void main() {
  final units = {UnitType.scout: Unit(type: UnitType.scout, count: 3)};
  Finder illustration(String path) => find.byWidgetPredicate(
      (w) => w is RasterSvg && w.assetPath == path);

  Future<void> show(WidgetTester t, Widget dialog) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () => showDialog<void>(
                context: ctx, builder: (_) => dialog),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('the descent shows the post it goes through', (t) async {
    await show(t, DescentDialog(
      availableUnits: units,
      targetLevel: 3,
      transitionBaseName: 'Cheminée Primaire',
      baseType: TransitionBaseType.cheminee,
      onConfirm: (_) {},
    ));
    expect(illustration('assets/icons/posts/cheminee_player.svg'),
        findsOneWidget);
  });

  testWidgets('the reinforcements show the post they go through',
      (t) async {
    await show(t, ReinforcementDialog(
      availableUnits: units,
      targetLevel: 2,
      transitionBaseName: 'Faille Alpha',
      baseType: TransitionBaseType.faille,
      onConfirm: (_) {},
    ));
    expect(illustration('assets/icons/posts/faille_player.svg'),
        findsOneWidget);
  });
}
