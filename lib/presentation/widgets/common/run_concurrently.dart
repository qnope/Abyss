/// Runs [task] on every item, with at most [workers] tasks in flight.
///
/// Lets independent async work (e.g. SVGs parsed in background isolates)
/// use several cores without flooding the device with all of it at once.
/// Fails with the first error once every worker has stopped.
Future<void> runConcurrently<T>(
  Iterable<T> items,
  int workers,
  Future<void> Function(T item) task,
) async {
  final queue = items.iterator;
  Future<void> worker() async {
    while (queue.moveNext()) {
      await task(queue.current);
    }
  }

  await Future.wait([for (var i = 0; i < workers; i++) worker()]);
}
