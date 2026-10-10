import 'package:abyss/domain/map/transition_base_name.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const faille = TransitionBaseType.faille;
  const cheminee = TransitionBaseType.cheminee;

  test('four failles and three cheminees, ranked from 0', () {
    expect(TransitionBaseName.allOf(faille).map((n) => n.rank), [0, 1, 2, 3]);
    expect(TransitionBaseName.allOf(cheminee).map((n) => n.rank), [0, 1, 2]);
    expect(
      TransitionBaseName.allOf(cheminee).map((n) => n.type).toSet(),
      {cheminee},
    );
  });

  test('a name is stored as a code read back as the same name', () {
    for (final type in TransitionBaseType.values) {
      for (final name in TransitionBaseName.allOf(type)) {
        expect(TransitionBaseName.parse(name.code), name);
      }
    }
    expect(const TransitionBaseName(faille, 2).code, 'faille:2');
  });

  test('reads the French names older saves stored', () {
    expect(TransitionBaseName.parse('Faille Alpha'),
        const TransitionBaseName(faille, 0));
    expect(TransitionBaseName.parse('Faille Delta'),
        const TransitionBaseName(faille, 3));
    expect(TransitionBaseName.parse('Cheminee Primaire'),
        const TransitionBaseName(cheminee, 0));
    expect(TransitionBaseName.parse('Cheminee Tertiaire'),
        const TransitionBaseName(cheminee, 2));
  });

  test('any other text names no known base', () {
    expect(TransitionBaseName.parse('Faille Noire'), isNull);
    expect(TransitionBaseName.parse(''), isNull);
    expect(TransitionBaseName.parse('faille:x'), isNull);
    expect(TransitionBaseName.parse('volcan:0'), isNull);
  });
}
