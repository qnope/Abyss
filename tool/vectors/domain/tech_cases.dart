import 'package:abyss/domain/tech/tech_branch.dart';

/// The researches of the tech vectors.
abstract final class TechCases {
  /// Every state an unlocked branch can be in: its level and the options
  /// taken at levels 2 and 4.
  static final List<(int, List<int>)> states = <(int, List<int>)>[
    (0, []),
    (1, []),
    for (final int first in const [0, 1]) ...[
      (2, [first]),
      (3, [first]),
      for (final int second in const [0, 1]) ...[
        (4, [first, second]),
        (5, [first, second]),
      ],
    ],
  ];

  /// Researches of a whole player: one branch alone in each of its
  /// states, then several branches together.
  static final List<Map<TechBranch, (int, List<int>)>> researches = [
    {},
    for (final TechBranch branch in TechBranch.values)
      for (final (int, List<int>) state in states) {branch: state},
    {
      TechBranch.military: (5, [0, 0]),
      TechBranch.resources: (5, [0, 0]),
      TechBranch.explorer: (5, [0, 0]),
    },
    {
      TechBranch.military: (5, [1, 1]),
      TechBranch.resources: (5, [1, 1]),
      TechBranch.explorer: (5, [1, 1]),
    },
    {
      TechBranch.military: (3, [1]),
      TechBranch.resources: (4, [0, 1]),
      TechBranch.explorer: (2, [0]),
    },
  ];
}
