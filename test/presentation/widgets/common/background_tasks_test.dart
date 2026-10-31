import 'dart:async';

import 'package:abyss/presentation/widgets/common/background_tasks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runs each task later, alone in its turn, in the order asked',
      () async {
    final ran = <String>[];
    final done = Completer<void>();
    var turn = 0;
    final turns = <int>[];
    BackgroundTasks.run(() {
      ran.add('a');
      turns.add(turn);
      // Counts the turns of the event loop from now on.
      Timer.run(() => turn++);
    });
    BackgroundTasks.run(() {
      ran.add('b');
      turns.add(turn);
    });
    BackgroundTasks.run(() {
      ran.add('c');
      done.complete();
    });
    expect(ran, isEmpty, reason: 'never within the turn asking');
    await done.future;
    expect(ran, ['a', 'b', 'c']);
    expect(turns.last, greaterThan(turns.first), reason: 'a turn apart');
  });

  test('goes on after a task that throws', () async {
    final done = Completer<void>();
    final reported = <Object>[];
    final report = FlutterError.onError;
    FlutterError.onError = (details) => reported.add(details.exception);
    addTearDown(() => FlutterError.onError = report);
    BackgroundTasks.run(() => throw StateError('lost'));
    BackgroundTasks.run(done.complete);
    await done.future;
    expect(reported.single, isStateError);
  });

  testWidgets('runs out of the time a widget test fakes', (tester) async {
    var ran = false;
    BackgroundTasks.run(() => ran = true);
    await tester.pump();
    expect(ran, isFalse);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)));
    expect(ran, isTrue);
  });

  test('drops the tasks queued once reset, then runs the new ones',
      () async {
    final ran = <String>[];
    final done = Completer<void>();
    BackgroundTasks.run(() => ran.add('stale'));
    BackgroundTasks.run(() => ran.add('stale too'));

    BackgroundTasks.debugReset();
    BackgroundTasks.run(() => ran.add('fresh'));
    BackgroundTasks.run(done.complete);

    await done.future;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(ran, ['fresh']);
  });
}
