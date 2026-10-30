import 'dart:ui';

import 'package:abyss/presentation/widgets/army/army_plaque.dart';
import 'package:abyss/presentation/widgets/army/army_plaque_drawer.dart';
import 'package:abyss/presentation/widgets/army/squad_arrival.dart';
import 'package:abyss/presentation/widgets/base/base_pad_tier.dart';

/// A squad of scouts going from 3 to 8 as its recruit arrives.
const before = ArmyPlaque(name: 'Éclaireurs', colour: colour, count: '3');
const after = ArmyPlaque(name: 'Éclaireurs', colour: colour, count: '8');
const arrival = SquadArrival(figure: 2, stays: true, gained: 5);
const colour = Color(0xFF3366FF);

/// Plaques drawing nothing, each one drawn logged in [log] as #plaque
/// with the plaque and its centre, all reaching [right] on each side.
class LoggedPlaques extends ArmyPlaqueDrawer {
  static const right = 40 * basePadUnit;

  final List<(Symbol, List<dynamic>)> log;

  const LoggedPlaques(this.log);

  @override
  (double, double) reach(ArmyPlaque plaque) => (right, right);

  @override
  void paint(Canvas canvas, Offset at, ArmyPlaque plaque) =>
      log.add((#plaque, [plaque, at]));
}
