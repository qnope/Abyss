import 'dart:convert';

import 'action_codec.dart';
import 'action_spec.dart';
import 'script_library.dart';
import 'timeline_script.dart';

/// Reads a JSON scenario into a [TimelineScript]:
///
/// ```json
/// {
///   "name": "rush-caserne",
///   "otherwise": "economy",
///   "turns": {
///     "1": [{"do": "upgrade", "building": "headquarters"}],
///     "3": [{"do": "recruit", "unit": "harpoonist", "count": 4}]
///   }
/// }
/// ```
///
/// `otherwise` names a built-in strategy that plays the turns left out.
abstract final class ScenarioParser {
  static TimelineScript parse(String source) {
    final Object? json = jsonDecode(source);
    if (json is! Map<String, Object?>) {
      throw const FormatException('Un scénario est un objet JSON');
    }
    final Object turns = json['turns'] ?? <String, Object?>{};
    if (turns is! Map<String, Object?>) {
      throw const FormatException('"turns" doit être un objet');
    }
    final Object? otherwise = json['otherwise'];
    return TimelineScript(
      name: json['name'] as String? ?? 'scenario',
      turns: <int, List<ActionSpec>>{
        for (final MapEntry<String, Object?> e in turns.entries)
          _turnOf(e.key): _actionsOf(e.value),
      },
      otherwise: otherwise is String ? ScriptLibrary.byName(otherwise) : null,
    );
  }

  static int _turnOf(String key) {
    final int? turn = int.tryParse(key);
    if (turn == null || turn < 1) {
      throw FormatException('Numéro de tour invalide : $key');
    }
    return turn;
  }

  static List<ActionSpec> _actionsOf(Object? value) {
    if (value is! List) {
      throw const FormatException('Chaque tour est une liste d\'actions');
    }
    return <ActionSpec>[
      for (final Object? action in value)
        ActionCodec.decode(Map<String, Object?>.from(action as Map)),
    ];
  }
}
