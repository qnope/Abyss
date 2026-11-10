import 'package:abyss/domain/faction/faction_catalogue.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/reference/reference_arguments.dart';
import 'package:abyss/domain/reference/reference_source.dart';
import 'package:flutter_test/flutter_test.dart';

String _noFile(String path) => throw StateError('no file read: $path');

ReferenceSource _source(List<String> args) =>
    ReferenceArguments.parse(args).source(_noFile);

void main() {
  test('reads options with a value and flags', () {
    final options = ReferenceArguments.parse([
      '--check',
      '--out',
      'a.json',
      '--turns',
      '12',
    ]);

    expect(options.has('check'), isTrue);
    expect(options['check'], '');
    expect(options['out'], 'a.json');
    expect(options.number('turns'), 12);
    expect(options.has('update'), isFalse);
    expect(options.number('seed'), isNull);
  });

  test('refuses a stray word and a number that is not one', () {
    expect(() => ReferenceArguments.parse(['oops']), throwsFormatException);
    expect(
      () => ReferenceArguments.parse(['--turns', 'many']).number('turns'),
      throwsFormatException,
    );
  });

  test('describes a strategy game, with the defaults of the simulator', () {
    expect(_source([]).toJson(), {
      'strategy': 'balanced',
      'seed': 1,
      'difficulty': 'normal',
      'factions': <String>[],
      'turns': 60,
    });
    expect(
      _source([
        '--strategy',
        'rush',
        '--seed',
        '9',
        '--difficulty',
        'hard',
        '--turns',
        '80',
      ]).toJson(),
      {
        'strategy': 'rush',
        'seed': 9,
        'difficulty': 'hard',
        'factions': <String>[],
        'turns': 80,
      },
    );
  });

  test('a scenario replaces the strategy', () {
    final source = _source(['--scenario', 'scenarios/x.json']);

    expect(source.scenario, 'scenarios/x.json');
    expect(source.strategy, isNull);
  });

  test('a number of factions draws them with the seed, as the game does', () {
    expect(
      _source(['--factions', '3', '--seed', '4']).factions,
      FactionCatalogue.draw(3, seed: 4),
    );
    expect(_source(['--factions', '0']).factions, isEmpty);
  });

  test('factions are also given by name, in playing order', () {
    expect(_source(['--factions', 'magmaSmiths,pearlOrder']).factions, [
      FactionPersonality.magmaSmiths,
      FactionPersonality.pearlOrder,
    ]);
    expect(() => _source(['--factions', 'nobody']), throwsArgumentError);
  });

  test('--reference takes the source of an existing reference file', () {
    final source = ReferenceArguments.parse(['--reference', 'r.json']).source(
      (path) =>
          path == 'r.json'
              ? '{"source":{"strategy":"economy","seed":6,"difficulty":"easy",'
                  '"factions":["anglerCult"],"turns":44}}'
              : _noFile(path),
    );

    expect(source.toJson(), {
      'strategy': 'economy',
      'seed': 6,
      'difficulty': 'easy',
      'factions': ['anglerCult'],
      'turns': 44,
    });
  });
}
