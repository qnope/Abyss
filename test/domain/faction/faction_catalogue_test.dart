import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_catalogue.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the catalogue holds the ten personalities, each with a name', () {
    expect(FactionPersonality.values, hasLength(10));
    final names = FactionPersonality.values.map((p) => p.label).toSet();
    expect(names, hasLength(10));
    expect(names, contains("Les Pillards de l'Épave"));
    expect(names, contains('Les Fidèles du Kraken'));
  });

  test('a faction takes its id and name from its personality', () {
    final faction = Faction(FactionPersonality.silenceMonks);

    expect(faction.id, 'faction-silenceMonks');
    expect(faction.name, 'Les Moines du Silence');
  });

  test('a draw has no duplicate, whatever the seed and the count', () {
    for (var seed = 0; seed < 40; seed++) {
      for (var count = 1; count <= 10; count++) {
        final drawn = FactionCatalogue.draw(count, seed: seed);
        expect(drawn, hasLength(count));
        expect(drawn.toSet(), hasLength(count));
      }
    }
  });

  test('a seed always draws the same factions, in the same order', () {
    expect(
      FactionCatalogue.draw(5, seed: 7),
      FactionCatalogue.draw(5, seed: 7),
    );
  });

  test('other seeds draw other factions', () {
    final draws = {
      for (var seed = 0; seed < 20; seed++)
        FactionCatalogue.draw(3, seed: seed).join(','),
    };
    expect(draws.length, greaterThan(5));
  });

  test('a draw holds 1 to 10 factions', () {
    expect(() => FactionCatalogue.draw(0, seed: 1), throwsArgumentError);
    expect(() => FactionCatalogue.draw(11, seed: 1), throwsArgumentError);
  });
}
