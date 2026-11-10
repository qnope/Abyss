import '../faction/faction_catalogue.dart';
import '../faction/faction_personality.dart';
import '../game/difficulty.dart';
import 'reference_set.dart';
import 'reference_source.dart';

/// The command line of `bin/export_reference.dart`: `--name value` pairs
/// and flags.
class ReferenceArguments {
  final Map<String, String> options;

  const ReferenceArguments(this.options);

  factory ReferenceArguments.parse(List<String> args) {
    final Map<String, String> options = <String, String>{};
    for (int i = 0; i < args.length; i++) {
      if (!args[i].startsWith('--')) {
        throw FormatException('Option expected: ${args[i]}');
      }
      final bool valued = i + 1 < args.length && !args[i + 1].startsWith('--');
      options[args[i].substring(2)] = valued ? args[++i] : '';
    }
    return ReferenceArguments(options);
  }

  bool has(String name) => options.containsKey(name);

  String? operator [](String name) => options[name];

  /// The value of [name] as a number, or `null` when it is not given.
  int? number(String name) {
    final String? value = options[name];
    if (value == null) return null;
    return int.tryParse(value) ??
        (throw FormatException('--$name takes a number: $value'));
  }

  /// The source to play: the one of the `--reference` file ([read] gives
  /// its text), or the one the options describe.
  ReferenceSource source(String Function(String path) read) {
    final String? reference = options['reference'];
    if (reference != null) return ReferenceSet.sourceOf(read(reference));
    final String? scenario = options['scenario'];
    final int seed = number('seed') ?? 1;
    return ReferenceSource(
      strategy: scenario == null ? options['strategy'] ?? 'balanced' : null,
      scenario: scenario,
      seed: seed,
      difficulty: Difficulty.values.byName(options['difficulty'] ?? 'normal'),
      factions: _factions(options['factions'], seed),
      turns: number('turns') ?? 60,
    );
  }

  /// A number of factions, drawn from the catalogue with the seed, or
  /// their personalities by name, in playing order.
  static List<FactionPersonality> _factions(String? value, int seed) {
    if (value == null || value == '0') return const <FactionPersonality>[];
    final int? count = int.tryParse(value);
    if (count != null) return FactionCatalogue.draw(count, seed: seed);
    return <FactionPersonality>[
      for (final String name in value.split(','))
        FactionPersonality.values.byName(name),
    ];
  }
}
