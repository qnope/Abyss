import 'package:flutter/widgets.dart';

import '../../../domain/game/game.dart';
import '../../widgets/map/effects/map_effects.dart';
import 'game_screen_end_turn.dart';
import 'story/turn_story.dart';
import 'story/turn_story_snapshot.dart';

/// Watches the turn of [game] to tell its story on the map, through
/// [effects], as soon as it ends: [showLevel] brings the map of a level
/// on screen; [onTold] receives the story being told, over once the
/// future completes. Nothing is told when the player asks for fewer
/// animations, or when the turn changed nothing on the map.
TurnObserver watchTurnStory(
  BuildContext context,
  Game game,
  MapEffects effects, {
  required ValueChanged<int> showLevel,
  required ValueChanged<Future<void>> onTold,
}) =>
    () {
      if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return null;
      final before = TurnStorySnapshot.of(game.humanPlayer);
      return (result) {
        final story = TurnStory.plan(game, before, result);
        if (story.isEmpty) return;
        onTold(tellTurnStory(story, effects, showLevel: showLevel));
      };
    };

/// Tells [story] chapter after chapter: [showLevel] brings the map of the
/// chapter on screen, where [effects] plays it from the map's very first
/// frame. Stops as soon as the player skips.
Future<void> tellTurnStory(
  TurnStory story,
  MapEffects effects, {
  required ValueChanged<int> showLevel,
}) async {
  final skips = effects.skips;
  for (final chapter in story.chapters) {
    if (effects.skips != skips) return;
    showLevel(chapter.level);
    await effects.play(chapter.effect, awaitStage: true);
  }
}
