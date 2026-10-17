import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/presentation/extensions/faction_personality_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  test('every faction tells a distinct origin in each language', () {
    for (final l10n in [fr, en, es]) {
      final origins = FactionPersonality.values.map((p) => p.origin(l10n));
      expect(origins.every((o) => o.isNotEmpty), isTrue);
      expect(origins.toSet(), hasLength(FactionPersonality.values.length));
    }
  });

  test('tells where the factions come from in French', () {
    expect(
      FactionPersonality.pearlOrder.origin(fr),
      "L'équipage d'un navire-chantier, "
      'pour qui une perle se mérite avec le temps.',
    );
    expect(FactionPersonality.krakenFaithful.origin(fr), contains('Naufrage'));
  });

  test('reuses the lore vocabulary in English and Spanish', () {
    expect(FactionPersonality.krakenFaithful.origin(en), contains('Trench'));
    expect(FactionPersonality.krakenFaithful.origin(es), contains('Fosa'));
    expect(FactionPersonality.magmaSmiths.origin(en), contains('Volcano'));
    expect(FactionPersonality.magmaSmiths.origin(es), contains('Volcán'));
  });
}
