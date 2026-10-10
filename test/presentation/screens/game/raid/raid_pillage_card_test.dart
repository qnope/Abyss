import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/presentation/extensions/resource_type_extensions.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/screens/game/raid/raid_pillage_card.dart';
import 'package:abyss/presentation/widgets/resource/resource_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/l10n_fixtures.dart';
import '../../../../helpers/localized_app.dart';
import '../../../../helpers/test_svg_helper.dart';

void main() {
  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  Future<void> show(WidgetTester tester, Map<ResourceType, int> pillaged) =>
      tester.pumpWidget(localizedApp(
        locale: AbyssLocale.en,
        Scaffold(body: RaidPillageCard(pillaged: pillaged)),
      ));

  testWidgets('lists each resource the monsters carried away', (
    tester,
  ) async {
    await show(tester, {ResourceType.coral: 40, ResourceType.ore: 0});

    expect(find.text(en.raidPillage), findsOneWidget);
    expect(find.text('${ResourceType.coral.displayName(en)} -40'),
        findsOneWidget);
    expect(find.byType(ResourceIcon), findsOneWidget);
    expect(find.text(en.raidNothingToLoot), findsNothing);
  });

  testWidgets('says there was nothing to loot when nothing was taken', (
    tester,
  ) async {
    await show(tester, {ResourceType.coral: 0});

    expect(find.text(en.raidPillage), findsOneWidget);
    expect(find.text(en.raidNothingToLoot), findsOneWidget);
    expect(find.byType(ResourceIcon), findsNothing);
  });
}
