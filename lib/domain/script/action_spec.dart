import 'dart:math';

import '../action/action.dart';

/// Builds an action when a script is about to play it, with the game's
/// seeded generator for the actions that roll dice.
typedef ActionSpec = Action Function(Random random);
