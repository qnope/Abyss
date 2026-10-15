import 'package:abyss/domain/map/cell_content_type.dart';
import 'package:abyss/domain/map/map_cell.dart';
import 'package:abyss/domain/map/terrain_type.dart';
import 'package:abyss/presentation/extensions/cell_content_type_extensions.dart';
import 'package:abyss/presentation/extensions/monster_lair_extensions.dart';
import 'package:abyss/presentation/screens/game/story/turn_story.dart';
import 'package:abyss/presentation/screens/game/story/turn_story_snapshot.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_fog_lift.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_round.dart';
import 'package:flutter_test/flutter_test.dart';

import 'story_test_data.dart';

void main() {
  test('a turn that changed nothing on the map has no story', () {
    final game = storyGame();
    final before = TurnStorySnapshot.of(game.humanPlayer);
    expect(TurnStory.plan(game, before, storyResult()).isEmpty, isTrue);
  });

  test('the fog lifts from exactly the newly seen cells, with the scouts '
      'whose exploration is over', () {
    final game = storyGame(scouts: [(1, 8, 5), (2, 3, 3)]);
    final before = TurnStorySnapshot.of(game.humanPlayer);
    revealAfterTurn(game, 1, [(5, 5), (8, 5), (9, 5), (9, 6)]);
    final story = TurnStory.plan(game, before, storyResult());
    expect(story.chapters, hasLength(1));
    final chapter = story.chapters.single;
    expect(chapter.level, 1);
    final lift = chapter.effect as MapFogLift;
    expect(lift.cells.keys.toSet(), {(8, 5), (9, 5), (9, 6)});
    expect(lift.scouts, {(8, 5)});
    expect(lift.focus, (8, 5));
  });

  test('a wreck not searched yet stays seen above the lifting fog', () {
    final game = storyGame();
    final map = game.levels[1]!;
    final wreck = MapCell(
        terrain: TerrainType.plain, content: CellContentType.wreck);
    map.setCell(8, 5, wreck);
    map.setCell(9, 5, wreck.copyWith(collectedBy: 'Nemo'));
    final before = TurnStorySnapshot.of(game.humanPlayer);
    revealAfterTurn(game, 1, [(8, 5), (9, 5), (9, 6)]);
    final story = TurnStory.plan(game, before, storyResult());
    final lift = story.chapters.single.effect as MapFogLift;
    expect(lift.beacons, {(8, 5): CellContentType.wreck.svgPath});
  });

  test('the fog lifts on the level where the most cells were seen', () {
    final game = storyGame();
    final before = TurnStorySnapshot.of(game.humanPlayer);
    revealAfterTurn(game, 1, [(0, 0)]);
    revealAfterTurn(game, 2, [(1, 1), (1, 2), (2, 1)]);
    final story = TurnStory.plan(game, before, storyResult());
    expect(story.chapters.single.level, 2);
  });

  test('a raid fought on the base comes after the fog, on level 1', () {
    final game = storyGame();
    final before = TurnStorySnapshot.of(game.humanPlayer);
    revealAfterTurn(game, 2, [(1, 1)]);
    final story = TurnStory.plan(
        game, before, storyResult(raid: storyRaid(victory: false)));
    expect(story.chapters.map((c) => c.level), [2, 1]);
    final siege = story.chapters.last.effect as MapSiege;
    expect(siege.place, (5, 5));
    expect(siege.span, 1);
    expect(siege.victory, isFalse);
    expect(siege.attackerSprite, storyWave.svgPath);
    expect(siege.focus, (5, 5));
    expect(siege.rounds, [(dealt: 10, taken: 5), (dealt: 7, taken: 3)]);
  });

  test('a wave fought on the kernel plays on its level, over the volcano',
      () {
    final game = storyGame();
    final before = TurnStorySnapshot.of(game.humanPlayer);
    final story = TurnStory.plan(game, before,
        storyResult(volcano: storyVolcano(victory: true)));
    final chapter = story.chapters.single;
    expect(chapter.level, 3);
    final siege = chapter.effect as MapSiege;
    expect(siege.place, storyKernel);
    expect(siege.span, 2);
    expect(siege.victory, isTrue);
    expect(siege.rounds, roundsOf(storyVolcano(victory: true).fight));
    expect(siege.rounds, hasLength(2));
  });
}
