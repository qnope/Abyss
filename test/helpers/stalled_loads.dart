import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Starts [load] as a widget test does in its faked time, then leaves it
/// once over: what it awaits comes, but it never goes on, so a cache
/// holding it holds a load that never ends.
///
/// Only what is awaited asynchronously stalls: the SVGs it reads should
/// be decoded already, so that `svg.cache` gives them at once (and keeps
/// none stalled for later tests).
void startForever(Future<Object?> Function() load) => Zone.current
    .fork(specification: ZoneSpecification(scheduleMicrotask: _never))
    .run(() => load().ignore());

void _never(Zone self, ZoneDelegate parent, Zone zone, void Function() f) {}

/// What [load] gives in real time, failing the test with a timeout
/// rather than hanging when it never comes.
Future<T?> loadsWithin<T>(WidgetTester tester, Future<T> Function() load) =>
    tester.runAsync(() => load().timeout(const Duration(seconds: 10)));

/// Checks [load] does not come in a while: it waits on one never ending.
Future<void> expectStalled<T>(
    WidgetTester tester, Future<T> Function() load) async {
  Object? error;
  await tester.runAsync(() => load()
      .timeout(const Duration(milliseconds: 300))
      .then<void>((_) {}, onError: (Object e) => error = e));
  expect(error, isA<TimeoutException>(), reason: 'the load should stall');
}
