import 'dart:ui' as ui;

import 'package:abyss/domain/map/monster_difficulty.dart';
import 'package:abyss/domain/map/monster_lair.dart';
import 'package:abyss/presentation/widgets/map/effects/map_effect.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/map_strike_run.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_geometry.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_marks.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_timeline.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
import 'package:abyss/presentation/widgets/map/map_sprites.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'strike_test_data.dart';

Matcher _near(Offset point) => within(distance: 1e-6, from: point);

void main() {
  const lair = MonsterLair(difficulty: MonsterDifficulty.easy, unitCount: 1);
  const geometry = StrikeGeometry(origin: (0, 5), target: (5, 5));
  final body = MapProjection.standingOf((5, 5));

  Future<MapStrikeRun> runOf(WidgetTester tester) async {
    final sprites = await tester.runAsync(MapSprites.load);
    final strike = MapStrike.of(
        target: (5, 5),
        lair: lair,
        result: strikeResult(taken: const [2, 0]));
    return strike.stage(MapStage(originOf: (_) => (0, 5), sprites: sprites))
        as MapStrikeRun;
  }

  _Canvas paintAt(MapStrikeRun run, Duration elapsed) {
    final canvas = _Canvas();
    run.paint(canvas, elapsed);
    return canvas;
  }

  testWidgets('the monster attacked stands where the map draws it',
      (tester) async {
    final run = await runOf(tester);
    final canvas = paintAt(run, run.timeline.hitAt(0));
    expect(canvas.images, contains(body));
  });

  testWidgets('a beaten monster shrinks to its foot as it fades',
      (tester) async {
    final run = await runOf(tester);
    final outcome = run.timeline.pace.end + StrikeTimeline.outcome ~/ 2;
    final shrunk = paintAt(run, outcome).images.first;
    expect(shrunk.width, lessThan(body.width));
    expect(shrunk.bottom, closeTo(body.bottom, 1e-6));
    expect(shrunk.center.dx, closeTo(body.center.dx, 1e-6));
  });

  testWidgets('the army token stands upright where it swims on the flat map',
      (tester) async {
    final run = await runOf(tester);
    for (final (at, swim) in [(Duration.zero, 0.0), (run.timeline.swim, 1.0)]) {
      final token = paintAt(run, at).discs.single;
      final flat = geometry.tokenRect(swim: swim).center;
      expect(token, _near(MapProjection.toScreen(flat)));
    }
  });

  testWidgets('the losses float up from the top of the monster and of the '
      'army token', (tester) async {
    final run = await runOf(tester);
    final army = MapProjection.upright(geometry.tokenRect(swim: 1));
    final numbers = paintAt(run, run.timeline.hitAt(0)).numbers;
    expect(numbers, hasLength(3), reason: 'the badge and two losses');
    expect(numbers[1], _near(body.topCenter));
    expect(numbers[2], _near(army.topCenter));
  });
}

/// A canvas keeping the images, the token discs (larger than a badge)
/// and the middle of the texts drawn on it.
class _Canvas implements Canvas {
  final images = <Rect>[];
  final discs = <Offset>[];
  final numbers = <Offset>[];

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {
    if (paint.colorFilter == null) images.add(dst);
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    if (paint.style == PaintingStyle.fill &&
        radius > StrikeMarks.badgeRadius) {
      discs.add(c);
    }
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) =>
      numbers.add(offset +
          Offset(paragraph.maxIntrinsicWidth, paragraph.height) / 2);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
