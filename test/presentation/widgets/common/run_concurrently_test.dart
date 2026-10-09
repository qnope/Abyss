import 'package:abyss/presentation/widgets/common/run_concurrently.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runs every task, at most [workers] at a time', () async {
    var running = 0;
    var peak = 0;
    final done = <int>[];
    await runConcurrently(List.generate(10, (i) => i), 3, (i) async {
      running++;
      peak = running > peak ? running : peak;
      await Future<void>.delayed(Duration(milliseconds: 10 - i));
      running--;
      done.add(i);
    });
    expect(done..sort(), List.generate(10, (i) => i));
    expect(peak, 3);
  });

  test('completes at once with no task', () async {
    await runConcurrently(<int>[], 4, (_) async => fail('no task to run'));
  });

  test('reports the first failure once every worker stops', () async {
    final run = runConcurrently([0, 1, 2], 2, (i) async {
      if (i == 0) throw StateError('broken');
    });
    await expectLater(run, throwsStateError);
  });
}
