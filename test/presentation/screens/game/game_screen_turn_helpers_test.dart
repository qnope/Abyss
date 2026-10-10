import 'package:abyss/domain/building/building.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/event/random_event_type.dart';
import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/game/player.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/turn/player_turn_resolver.dart';
import 'package:abyss/domain/unit/unit.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/screens/game/game_screen_turn_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../domain/event/event_test_helper.dart';

/// Producing player during turn 12 under the lasting [event], with
/// [algae] in store, [energy] in store and [harpoonists] to feed.
Game _game(
  RandomEventType? event, {
  bool heating = false,
  int algae = 100,
  int energy = 100,
  int harpoonists = 0,
}) {
  final Player player = producingPlayer();
  if (event != null) {
    player.eventState
      ..activate(event, untilTurn: 14)
      ..heating = heating;
  }
  player.resources[ResourceType.algae]!.amount = algae;
  player.resources[ResourceType.energy]!.amount = energy;
  player.unitsPerLevel[1]![UnitType.harpoonist] =
      Unit(type: UnitType.harpoonist, count: harpoonists);
  return Game.singlePlayer(player)..turn = 12;
}

/// The preview of the end-of-turn confirmation matches what the end of
/// turn really does.
void _expectPreviewMatches(Game Function() build) {
  final preview = build();
  final player = preview.humanPlayer;
  final production = computeProduction(preview, player);
  final consumption = computeConsumption(preview, player);
  final deactivated = computeBuildingsToDeactivate(preview, player, production);
  final lost = computeUnitsToLose(preview, player, deactivated);

  final played = build();
  final result = PlayerTurnResolver.resolve(
    played.humanPlayer,
    played.turn,
    difficulty: played.difficulty,
  );
  expect(deactivated, result.deactivatedBuildings);
  expect(lost, result.lostUnits);
  if (deactivated.isNotEmpty) return;
  for (final change in result.changes) {
    expect(production[change.type] ?? 0, change.produced,
        reason: '${change.type}');
    if (change.type == ResourceType.energy) {
      expect(consumption[ResourceType.energy] ?? 0, change.consumed);
    }
  }
}

void main() {
  test('the preview matches the end of turn without an event', () {
    _expectPreviewMatches(() => _game(null));
  });

  test('the preview matches the end of turn of a warm current', () {
    _expectPreviewMatches(() => _game(RandomEventType.warmCurrent));
  });

  test('the preview matches the end of turn of a cold current', () {
    _expectPreviewMatches(() => _game(RandomEventType.coldCurrent));
  });

  test('the preview matches the end of turn of heated farms', () {
    _expectPreviewMatches(
      () => _game(RandomEventType.coldCurrent, heating: true),
    );
  });

  test('the preview counts the units a cold current starves', () {
    final game = _game(RandomEventType.coldCurrent, algae: 0, harpoonists: 100);
    final player = game.humanPlayer;
    final lost = computeUnitsToLose(game, player, const []);
    final calm = _game(null, algae: 0, harpoonists: 100);
    expect(lost[UnitType.harpoonist],
        greaterThan(computeUnitsToLose(calm, calm.humanPlayer, const [])
                [UnitType.harpoonist] ??
            0));
    _expectPreviewMatches(
      () => _game(RandomEventType.coldCurrent, algae: 0, harpoonists: 100),
    );
  });

  test('heating is paid before the buildings, in the preview too', () {
    Game build() =>
        _game(RandomEventType.coldCurrent, heating: true, energy: 0);
    final game = build();
    final player = game.humanPlayer;
    player.buildings[BuildingType.solarPanel] =
        Building(type: BuildingType.solarPanel, level: 1);
    final deactivated = computeBuildingsToDeactivate(
        game, player, computeProduction(game, player));
    expect(deactivated, isNotEmpty);
    _expectPreviewMatches(() {
      final g = build();
      g.humanPlayer.buildings[BuildingType.solarPanel] =
          Building(type: BuildingType.solarPanel, level: 1);
      return g;
    });
  });
}
