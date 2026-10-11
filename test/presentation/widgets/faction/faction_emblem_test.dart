import 'dart:io';

import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/faction/faction_emblem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

void main() {
  test('the first three factions have an emblem that exists', () {
    for (final p in [
      FactionPersonality.wreckPillagers,
      FactionPersonality.pearlOrder,
      FactionPersonality.anglerCult,
    ]) {
      final asset = FactionEmblem.assetOf(p);
      expect(asset, isNotNull);
      expect(File(asset!).existsSync(), isTrue);
    }
  });

  test('every emblem is its own picture', () {
    final assets = {
      for (final p in FactionPersonality.values) FactionEmblem.assetOf(p),
    }..remove(null);
    expect(assets, hasLength(3));
  });

  testWidgets('a faction without an emblem shows its colour', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const FactionEmblem(personality: FactionPersonality.murenaHorde),
      ),
    );
    expect(find.byIcon(Icons.circle), findsOneWidget);
    expect(find.byType(RasterSvg), findsNothing);
  });

  testWidgets('a faction with an emblem draws it', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const FactionEmblem(personality: FactionPersonality.pearlOrder),
      ),
    );
    expect(find.byType(RasterSvg), findsOneWidget);
  });
}
