import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/map/post_holder.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/post_holder_extensions.dart';

void main() {
  test('each post has its illustration for each holder', () {
    expect(TransitionBaseType.faille.svgPathFor(PostHolder.guardians),
        'assets/icons/posts/faille_guarded.svg');
    expect(TransitionBaseType.faille.svgPathFor(PostHolder.human),
        'assets/icons/posts/faille_player.svg');
    expect(TransitionBaseType.cheminee.svgPathFor(PostHolder.faction),
        'assets/icons/posts/cheminee_faction.svg');
  });

  test('each passage below has its illustration for each holder', () {
    expect(TransitionBaseType.faille.passageSvgPathFor(PostHolder.human),
        'assets/icons/posts/passage_faille_player.svg');
    expect(TransitionBaseType.cheminee.passageSvgPathFor(PostHolder.guardians),
        'assets/icons/posts/passage_cheminee_guarded.svg');
  });

  test('every path points to an existing asset', () {
    for (final path in postSvgPaths) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
    expect(postSvgPaths, hasLength(12));
  });

}
