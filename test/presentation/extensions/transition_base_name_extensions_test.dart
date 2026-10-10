import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_name.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/extensions/transition_base_name_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const faille = TransitionBaseType.faille;
  const cheminee = TransitionBaseType.cheminee;

  test('words every faille in each language', () {
    final names = TransitionBaseName.allOf(faille);
    expect(names.map((n) => n.displayName(fr)),
        ['Faille Alpha', 'Faille Bêta', 'Faille Gamma', 'Faille Delta']);
    expect(names.map((n) => n.displayName(en)),
        ['Alpha Rift', 'Beta Rift', 'Gamma Rift', 'Delta Rift']);
    expect(names.map((n) => n.displayName(es)),
        ['Falla Alfa', 'Falla Beta', 'Falla Gamma', 'Falla Delta']);
  });

  test('words every cheminee in each language', () {
    final names = TransitionBaseName.allOf(cheminee);
    expect(names.map((n) => n.displayName(fr)), [
      'Cheminée Primaire', 'Cheminée Secondaire', 'Cheminée Tertiaire',
    ]);
    expect(names.map((n) => n.displayName(en)),
        ['Primary Vent', 'Secondary Vent', 'Tertiary Vent']);
    expect(names.map((n) => n.displayName(es)), [
      'Chimenea Primaria', 'Chimenea Secundaria', 'Chimenea Terciaria',
    ]);
  });

  test('a rank no map generates is numbered after its type', () {
    expect(const TransitionBaseName(faille, 5).displayName(en),
        'Abyssal Rift 6');
  });

  test('words a stored name, older French ones included', () {
    expect(baseNameLabel(en, 'faille:1'), 'Beta Rift');
    expect(baseNameLabel(es, 'Cheminee Primaire'), 'Chimenea Primaria');
    expect(baseNameLabel(fr, 'Cheminee Primaire'), 'Cheminée Primaire');
  });

  test('shows any other stored text as it is', () {
    expect(baseNameLabel(en, 'Faille Noire'), 'Faille Noire');
  });

  test('words the name of a base', () {
    final base = TransitionBase(type: cheminee, name: 'cheminee:2');
    expect(base.displayName(en), 'Tertiary Vent');
  });
}
