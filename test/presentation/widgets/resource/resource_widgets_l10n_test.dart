import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/resource/resource_detail_sheet.dart';
import 'package:abyss/presentation/widgets/resource/resource_gain_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';
import '../../../helpers/test_svg_helper.dart';

Future<void> _open(
  WidgetTester t,
  Locale locale,
  void Function(BuildContext) open,
) async {
  await t.pumpWidget(localizedApp(
    Scaffold(
      body: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => open(ctx),
          child: const Text('Open'),
        ),
      ),
    ),
    locale: locale,
  ));
  await t.tap(find.text('Open'));
  await t.pumpAndSettle();
}

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('a resource sheet in Spanish', (t) async {
    await _open(t, AbyssLocale.es, (ctx) => showResourceDetailSheet(
      ctx,
      Resource(type: ResourceType.coral, amount: 10),
      production: 4,
    ));
    expect(find.text('Producción'), findsOneWidget);
    expect(find.text('Edificio principal'), findsOneWidget);
  });

  testWidgets('nothing found, in English', (t) async {
    await _open(t, AbyssLocale.en, (ctx) => showResourceGainDialog(
      ctx,
      title: 'Ruins',
      deltas: const {},
    ));
    expect(find.text('Nothing to collect here...'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });
}
