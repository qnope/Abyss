import 'package:abyss/domain/game/player_defaults.dart';
import 'package:abyss/domain/resource/resource.dart';
import 'package:abyss/domain/resource/resource_credit.dart';
import 'package:abyss/domain/resource/resource_type.dart';

import '../vector_file.dart';
import 'resource_cases.dart';
import 'vector_inputs.dart';

/// What a player holds: the first stocks, the storage, a credit.
abstract final class ResourceStockSections {
  static final Map<String, VectorSection> sections = {
    'startingStocks': VectorSection(
      'PlayerDefaults.resources(): [amount, maxStorage] of each stock',
      () => [
        {
          'out': {
            for (final Resource r in PlayerDefaults.resources().values)
              r.type: [r.amount, r.maxStorage],
          },
        },
      ],
    ),
    'storage': VectorSection(
      'Resource(type: type, amount: 0, maxStorage: asked).maxStorage, '
          'and without maxStorage when asked is null',
      () => [
        for (final ResourceType type in ResourceType.values)
          for (final int? asked in const [null, 100, 1999, 2000, 5000])
            {
              'type': type,
              'asked': asked,
              'out': (asked == null
                      ? Resource(type: type, amount: 0)
                      : Resource(type: type, amount: 0, maxStorage: asked))
                  .maxStorage,
            },
      ],
    ),
    'credit': VectorSection(
      'ResourceCredit.add(resources, amounts): what was added, then '
          'the amounts left in stock; resources holds stocks under the '
          'storage of a new player (startingStocks), amounts as '
          '[type, amount] in order',
      () => [
        for (final c in ResourceCases.credits) _credit(c.$1, c.$2),
      ],
    ),
  };

  static Map<String, Object?> _credit(
    Map<ResourceType, int> stocks,
    Map<ResourceType, int> amounts,
  ) {
    final resources = VectorInputs.resources(stocks);
    final added = ResourceCredit.add(resources, amounts);
    return {
      'stocks': stocks,
      'amounts': [
        for (final e in amounts.entries) [e.key, e.value],
      ],
      'out': {
        'added': added,
        'stocks': {for (final r in resources.values) r.type: r.amount},
      },
    };
  }
}
