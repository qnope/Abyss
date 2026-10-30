import 'dart:ui' as ui;

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_fit.dart';
import 'package:abyss/presentation/widgets/army/army_roster.dart';
import 'package:abyss/presentation/widgets/army/army_sprites.dart';
import 'package:abyss/presentation/widgets/army/army_squads_painter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';

void main() {
  const view = Size(390, 635);
  final fit = ArmyFit.of(view);

  setUp(mockSvgAssets);
  tearDown(clearSvgMocks);

  testWidgets('each banner is recorded once, then replayed as it sways', (
    tester,
  ) async {
    final sprites = (await tester.runAsync(ArmySprites.load))!;
    final clock = ValueNotifier<double>(0);
    addTearDown(clock.dispose);
    final squads = ArmySquadsPainter(
      fit: fit,
      roster: const ArmyRoster(barracksLevel: 9),
      sprites: sprites,
      clock: clock,
    );
    squads.paint(Canvas(ui.PictureRecorder()), view);
    final recorded = ArmySquadsPainter.banners.recordings;
    for (final seconds in [.5, 1.0, 1.5]) {
      clock.value = seconds;
      var replays = 0;
      expect(
        (Canvas canvas) => squads.paint(canvas, view),
        paints..everything((method, arguments) {
          if (method == #drawPicture) replays++;
          return true;
        }),
      );
      expect(replays, UnitType.values.length, reason: 'at $seconds s');
    }
    expect(ArmySquadsPainter.banners.recordings, recorded);
  });
}
