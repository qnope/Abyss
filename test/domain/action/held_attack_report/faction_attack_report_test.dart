import 'package:abyss/domain/faction/faction_attack_report.dart';
import 'package:abyss/domain/history/history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/history_entry_samples.dart';

FactionAttackReport _report(BaseAssaultEntry entry) => FactionAttackReport(
  attackerId: 'nacre',
  attackerName: 'Nacre',
  personality: null,
  entry: entry,
);

void main() {
  test('a base attack has no post, passage nor losses below', () {
    final report = _report(baseAssaultEntry(victory: true, defending: true));

    expect(report.target, AttackTarget.base);
    expect(report.post, isNull);
    expect(report.passageLost, isNull);
    expect(report.levelBelow, isNull);
    expect(report.unitsLost, 0);
  });

  test('a post of an unknown name has no passage nor level', () {
    final entry = baseAssaultEntry(
      victory: true,
      defending: true,
      post: 'Atlantide',
    );

    final report = _report(entry);

    expect(report.target, AttackTarget.post);
    expect(report.outcome, AttackOutcome.postTaken);
    expect(report.post, isNull);
    expect(report.passageLost, isNull);
    expect(report.levelBelow, isNull);
  });

  test('a kernel report reads its target from the entry', () {
    final report = _report(
      baseAssaultEntry(
        victory: true,
        defending: true,
        post: 'volcanicKernel',
        kernel: (before: 1, after: 0),
      ),
    );

    expect(report.target, AttackTarget.kernel);
    expect(report.outcome, AttackOutcome.kernelTaken);
    expect(report.post, isNull);
  });
}
