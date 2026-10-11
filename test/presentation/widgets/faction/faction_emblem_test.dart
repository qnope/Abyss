import 'dart:io';

import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/presentation/widgets/common/raster_svg.dart';
import 'package:abyss/presentation/widgets/faction/faction_emblem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

void main() {
  test('every faction has an emblem of its own that exists', () {
    final assets = <String>{};
    for (final p in FactionPersonality.values) {
      final asset = FactionEmblem.assetOf(p);
      expect(File(asset).existsSync(), isTrue, reason: asset);
      assets.add(asset);
    }
    expect(assets, hasLength(FactionPersonality.values.length));
  });

  testWidgets('a faction draws its emblem', (tester) async {
    await tester.pumpWidget(
      localizedApp(
        const FactionEmblem(personality: FactionPersonality.pearlOrder),
      ),
    );
    expect(find.byType(RasterSvg), findsOneWidget);
  });
}
