import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/theme/abyss_theme.dart';
import 'package:abyss/presentation/widgets/unit/unit_detail_sheet.dart';
import '../../../helpers/test_svg_helper.dart';

final _defaultPlayer = Player(name: 'Tester');

Widget _app({
  UnitType unitType = UnitType.scout,
  int count = 0,
  bool isUnlocked = true,
  int barracksLevel = 1,
  bool hasRecruitedThisType = false,
  void Function(int)? onRecruit,
}) {
  return MaterialApp(
    theme: AbyssTheme.create(),
    home: Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => showUnitDetailSheet(
            ctx,
            unitType: unitType,
            count: count,
            isUnlocked: isUnlocked,
            barracksLevel: barracksLevel,
            resources: _defaultPlayer.resources,
            hasRecruitedThisType: hasRecruitedThisType,
            onRecruit: onRecruit ?? (_) {},
          ),
          child: const Text('Open'),
        ),
      ),
    ),
  );
}

Future<void> _openSheet(WidgetTester t) async {
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void _useTallSurface(WidgetTester t) {
  t.view.physicalSize = const Size(800, 1200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(() => t.view.resetPhysicalSize());
  addTearDown(() => t.view.resetDevicePixelRatio());
}

void main() {
  group('UnitDetailSheet', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    group('locked unit', () {
      testWidgets('shows unit name', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(
          unitType: UnitType.guardian,
          isUnlocked: false,
          barracksLevel: 0,
        ));
        await _openSheet(t);
        expect(find.text('Gardien'), findsOneWidget);
      });

      testWidgets('shows unlock requirement', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(
          unitType: UnitType.guardian,
          isUnlocked: false,
          barracksLevel: 0,
        ));
        await _openSheet(t);
        expect(
          find.text('Caserne niveau 3 requise pour debloquer'),
          findsOneWidget,
        );
      });

      testWidgets('does not show stats', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(
          unitType: UnitType.guardian,
          isUnlocked: false,
          barracksLevel: 0,
        ));
        await _openSheet(t);
        expect(find.textContaining('PV:'), findsNothing);
      });

      testWidgets('does not show slider', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(
          unitType: UnitType.guardian,
          isUnlocked: false,
          barracksLevel: 0,
        ));
        await _openSheet(t);
        expect(find.byType(Slider), findsNothing);
      });
    });

    group('unlocked unit', () {
      testWidgets('shows unit name', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(
          unitType: UnitType.harpoonist,
          count: 5,
        ));
        await _openSheet(t);
        expect(find.text('Harponneur'), findsOneWidget);
      });

      testWidgets('shows stats', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(count: 5));
        await _openSheet(t);
        expect(find.text('PV: 10'), findsOneWidget);
        expect(find.text('ATQ: 2'), findsOneWidget);
        expect(find.text('DEF: 1'), findsOneWidget);
      });

      testWidgets('shows current count', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(count: 5));
        await _openSheet(t);
        expect(find.text('En service: 5'), findsOneWidget);
      });

      testWidgets('shows recruitment section', (t) async {
        _useTallSurface(t);
        await t.pumpWidget(_app(count: 5));
        await _openSheet(t);
        expect(find.byType(Slider), findsOneWidget);
      });
    });
  });
}
