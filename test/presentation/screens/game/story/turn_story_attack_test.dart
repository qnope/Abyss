import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/extensions/monster_family_extensions.dart';
import 'package:abyss/presentation/extensions/unit_type_extensions.dart';
import 'package:abyss/presentation/screens/game/story/turn_story.dart';
import 'package:abyss/presentation/screens/game/story/turn_story_snapshot.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/faction_colors.dart';
import 'package:abyss/presentation/widgets/map/effects/story/map_siege.dart';
import 'package:flutter_test/flutter_test.dart';

import 'story_attack_data.dart';
import 'story_test_data.dart';

void main() {
  TurnStory storyOf(List<FactionAttackReport> attacks,
      {bool raid = false, FactionAttackReport? leviathan}) {
    final game = storyGame();
    placeStoryPosts(game);
    final before = TurnStorySnapshot.of(game.humanPlayer);
    return TurnStory.plan(
        game,
        before,
        storyResult(
          raid: raid ? storyRaid(victory: true) : null,
          attacks: attacks,
          leviathan: leviathan,
        ));
  }

  MapSiege siegeOf(TurnStory story, int i) =>
      story.chapters[i].effect as MapSiege;

  test('an attack on the base plays on the base, after the raid', () {
    final story = storyOf([storyAttack(victory: true)], raid: true);
    expect(story.chapters, hasLength(2));
    expect(story.chapters.last.level, 1);
    final siege = siegeOf(story, 1);
    expect(siege.place, (5, 5));
    expect(siege.span, 1);
    expect(siege.victory, isFalse);
  });

  test('an attack on a post plays on its cell, on its level', () {
    final story = storyOf([
      storyAttack(postName: storyFaille.code),
      storyAttack(postName: storyCheminee.code),
    ]);
    expect(story.chapters.map((c) => c.level), [1, 2]);
    expect(siegeOf(story, 0).place, storyFailleCell);
    expect(siegeOf(story, 1).place, storyChemineeCell);
    expect(siegeOf(story, 0).victory, isTrue);
  });

  test('an attack on the kernel plays over the volcano', () {
    final story = storyOf([storyKernelAttack()]);
    expect(story.chapters.single.level, 3);
    final siege = siegeOf(story, 0);
    expect(siege.place, storyKernel);
    expect(siege.span, 2);
  });

  test('attacks play in the order they were fought', () {
    final story = storyOf([
      storyKernelAttack(),
      storyAttack(postName: storyFaille.code),
      storyAttack(),
    ]);
    expect(story.chapters.map((c) => (c.effect as MapSiege).place),
        [storyKernel, storyFailleCell, (5, 5)]);
  });

  test('the defenders deal what the attackers took, and take the rest', () {
    final siege = siegeOf(storyOf([storyAttack()]), 0);
    expect(siege.rounds, [(dealt: 5, taken: 10), (dealt: 3, taken: 7)]);
  });

  test('the attackers show their leading unit, ringed in their colour', () {
    final siege = siegeOf(storyOf([storyAttack()]), 0);
    expect(siege.attackerSprite, UnitType.harpoonist.iconPath);
    expect(siege.imagePaths, contains(UnitType.harpoonist.iconPath));
    expect(siege.attackerRing,
        FactionColors.of(FactionPersonality.murenaHorde));
  });

  test('the guardians strike the Faille once, as monsters ringed in red',
      () {
    final leviathan = storyLeviathan();
    final story = storyOf([leviathan], leviathan: leviathan);
    final siege = siegeOf(story, 0);
    expect(story.chapters.single.level, 1);
    expect(siege.place, storyFailleCell);
    expect(siege.attackerSprite, krakenSvgPath);
    expect(siege.attackerRing, AbyssColors.error);
    expect(siege.victory, isFalse);
  });

  test('an attack on a post no map holds is not played', () {
    expect(storyOf([storyAttack(postName: 'faille:3')]).isEmpty, isTrue);
  });
}
