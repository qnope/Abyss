import 'package:abyss/domain/game/game_factory.dart';
import 'package:abyss/presentation/theme/abyss_colors.dart';
import 'package:abyss/presentation/theme/faction_colors.dart';
import 'package:abyss/presentation/widgets/faction/faction_base_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the human seals in cyan and each faction in its own colour', () {
    final game = GameFactory.newGame(
        playerName: 'Nemo', mapSeed: 7, factionCount: 2);
    final colors = kernelOwnerColors(game);
    expect(colors[game.humanPlayerId], AbyssColors.biolumCyan);
    for (final faction in game.factions) {
      expect(colors[faction.id], FactionColors.of(faction.personality));
    }
    expect(colors, hasLength(3));
  });

  test('a single-player game has only the human colour', () {
    final game = GameFactory.newGame(playerName: 'Nemo', mapSeed: 7);
    expect(kernelOwnerColors(game), {game.humanPlayerId: AbyssColors.biolumCyan});
  });
}
