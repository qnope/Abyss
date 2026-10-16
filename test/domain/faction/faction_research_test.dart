import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/faction_research.dart';
import 'package:abyss/domain/tech/tech_branch.dart';
import 'package:abyss/domain/tech/tech_option.dart';
import 'package:abyss/domain/tech/tech_perk.dart';
import 'package:flutter_test/flutter_test.dart';

/// Position of the [count]-th node of [branch] in [plan].
int _nth(List<TechBranch> plan, TechBranch branch, int count) {
  int seen = 0;
  for (int i = 0; i < plan.length; i++) {
    if (plan[i] == branch && ++seen == count) return i;
  }
  return -1;
}

void main() {
  const seekers = <FactionPersonality>{
    FactionPersonality.currentNomads,
    FactionPersonality.krakenFaithful,
    FactionPersonality.magmaSmiths,
  };

  test('every personality researches the Explorer branch', () {
    for (final p in FactionPersonality.values) {
      final plan = FactionResearch.planOf(p);
      expect(_nth(plan, TechBranch.explorer, 2), isNot(-1), reason: p.name);
    }
  });

  test('the default plan opens Explorer right after Military 3', () {
    final plan = FactionResearch.planOf(FactionPersonality.pearlOrder);
    expect(_nth(plan, TechBranch.explorer, 1),
        _nth(plan, TechBranch.military, 3) + 1);
    expect(_nth(plan, TechBranch.explorer, 3), -1);
  });

  test('the kernel seekers open Explorer earlier and go to node 3', () {
    final usual = FactionResearch.planOf(FactionPersonality.pearlOrder);
    for (final p in seekers) {
      final plan = FactionResearch.planOf(p);
      expect(_nth(plan, TechBranch.explorer, 1),
          _nth(plan, TechBranch.military, 2) + 1, reason: p.name);
      expect(_nth(plan, TechBranch.explorer, 1),
          lessThan(_nth(usual, TechBranch.explorer, 1)));
      expect(_nth(plan, TechBranch.explorer, 3),
          greaterThan(_nth(plan, TechBranch.resources, 3)));
    }
  });

  test('the factions take the Deep Sonar, the Monks the Silent Swim', () {
    TechPerk perk(FactionPersonality p) => TechPerk.of(TechBranch.explorer, 2,
        FactionResearch.picksOf(p)[TechBranch.explorer]!.first)!;
    for (final p in FactionPersonality.values) {
      expect(
        perk(p),
        p == FactionPersonality.silenceMonks
            ? TechPerk.silentSwim
            : TechPerk.deepSonar,
        reason: p.name,
      );
    }
    expect(FactionResearch.picksOf(FactionPersonality.pearlOrder)
        [TechBranch.explorer], [TechOption.a, TechOption.a]);
  });
}
