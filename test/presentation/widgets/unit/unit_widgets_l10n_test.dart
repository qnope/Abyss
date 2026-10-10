import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/domain/volcano/kernel_garrison.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/unit/recruitment_section.dart';
import 'package:abyss/presentation/widgets/unit/unit_card.dart';
import 'package:abyss/presentation/widgets/unit/unit_detail_sheet.dart';
import 'package:abyss/presentation/widgets/unit/unit_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

Future<void> _show(WidgetTester t, Widget child, Locale locale) =>
    t.pumpWidget(localizedApp(Scaffold(body: child), locale: locale));

Future<void> _open(
  WidgetTester t,
  Locale locale,
  void Function(BuildContext) open,
) async {
  await _show(
    t,
    Builder(
      builder: (ctx) => ElevatedButton(
        onPressed: () => open(ctx),
        child: const Text('Open'),
      ),
    ),
    locale,
  );
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void _sheet(BuildContext ctx, {required bool unlocked}) => showUnitDetailSheet(
  ctx,
  unitType: UnitType.harpoonist,
  count: 3,
  isUnlocked: unlocked,
  barracksLevel: 1,
  resources: Player(name: 'Tester').resources,
  hasRecruitedThisType: true,
  onRecruit: (_) {},
);

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a unit card counts its units in English', (t) async {
    await _show(
      t,
      UnitCard(
        unitType: UnitType.scout,
        countsPerLevel: const {1: 1},
        isUnlocked: true,
        onTap: () {},
      ),
      AbyssLocale.en,
    );
    expect(find.text('1 unit'), findsOneWidget);
  });

  testWidgets('a unit card tells where its units are in Spanish', (t) async {
    await _show(
      t,
      UnitCard(
        unitType: UnitType.scout,
        countsPerLevel: const {1: 2, KernelGarrison.stockKey: 3},
        isUnlocked: true,
        onTap: () {},
      ),
      AbyssLocale.es,
    );
    expect(find.text('Niv. 1: 2 · Núcleo: 3'), findsOneWidget);
  });

  testWidgets('a locked unit card in English', (t) async {
    await _show(
      t,
      UnitCard(
        unitType: UnitType.guardian,
        countsPerLevel: const {},
        isUnlocked: false,
        onTap: () {},
      ),
      AbyssLocale.en,
    );
    expect(find.text('Locked'), findsOneWidget);
  });

  testWidgets('the unit sheet in English', (t) async {
    await _open(t, AbyssLocale.en, (ctx) => _sheet(ctx, unlocked: true));
    expect(find.text('HP: 15'), findsOneWidget);
    expect(find.textContaining('ATK: '), findsOneWidget);
    expect(find.text('In service: 3'), findsOneWidget);
    expect(find.text('Already recruited this turn'), findsOneWidget);
  });

  testWidgets('a locked unit sheet in Spanish', (t) async {
    await _open(t, AbyssLocale.es, (ctx) => _sheet(ctx, unlocked: false));
    expect(find.textContaining('requeridos para desbloquear'), findsOneWidget);
  });

  testWidgets('recruiting in English', (t) async {
    await _show(
      t,
      RecruitmentSection(
        unitType: UnitType.scout,
        maxRecruitableCount: 0,
        hasRecruitedThisType: false,
        onRecruit: (_) {},
      ),
      AbyssLocale.en,
    );
    expect(find.text('Not enough resources'), findsOneWidget);
    await _show(
      t,
      RecruitmentSection(
        unitType: UnitType.scout,
        maxRecruitableCount: 4,
        hasRecruitedThisType: false,
        onRecruit: (_) {},
      ),
      AbyssLocale.es,
    );
    expect(find.text('0 unidades'), findsOneWidget);
    expect(find.text('Reclutar'), findsOneWidget);
  });

  testWidgets('the unit picker with no unit in English', (t) async {
    await _open(
      t,
      AbyssLocale.en,
      (ctx) => showUnitPickerDialog(
        ctx,
        title: 'Pick',
        availableUnits: {UnitType.scout: Unit(type: UnitType.scout, count: 0)},
        confirmLabel: 'Send',
      ),
    );
    expect(find.text('No units available.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });
}
