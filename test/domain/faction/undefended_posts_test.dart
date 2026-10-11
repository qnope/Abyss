import 'package:abyss/domain/faction/undefended_posts.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/post_attack_helper.dart';

List<TransitionBase> _of(PostWar war) =>
    UndefendedPosts.of(war.game, war.human);

void main() {
  test('a Faille with no unit on level 2 is undefended', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    expect(_of(war), [war.post]);
  });

  test('a Cheminée with no unit on level 3 is undefended', () {
    final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);
    expect(_of(war), [war.post]);
  });

  test('a single unit on the level below defends the post', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.put(war.human, 2, {UnitType.harpoonist: 1});
    expect(_of(war), isEmpty);
  });

  test('units on another level do not defend the post', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.put(war.human, 1, garrison);
    war.put(war.human, 3, garrison);
    expect(_of(war), [war.post]);
  });

  test('a post held by someone else is not the player\'s concern', () {
    final war = PostWar(TransitionBaseType.faille);
    expect(_of(war), isEmpty);
  });

  test('no post held, nothing undefended', () {
    final war = PostWar(TransitionBaseType.faille, humanHolds: true);
    war.post.capturedBy = null;
    expect(_of(war), isEmpty);
  });

  test('both posts undefended are listed, the Faille first', () {
    final war = PostWar(TransitionBaseType.cheminee, humanHolds: true);
    final rift = PostWar(TransitionBaseType.faille).at; // Same map seed.
    final TransitionBase faille =
        war.game.levels[1]!.cellAt(rift.x, rift.y).transitionBase!
          ..capturedBy = war.human.id;
    expect(_of(war), [faille, war.post]);
  });
}
