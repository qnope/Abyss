import 'isolate_job_stub.dart' if (dart.library.isolate) 'isolate_job_io.dart';

/// Shares numbered jobs between up to [workers] isolates and keeps their
/// results in job order.
///
/// Each worker takes the next job as soon as it is done with its own, so
/// a long job never holds the others up. Where isolates do not exist
/// (web), the jobs simply run inline.
class GameWorkers {
  final int workers;

  const GameWorkers(this.workers) : assert(workers >= 1);

  /// Runs `job(0)` to `job(count - 1)` and returns their results in order.
  Future<List<T>> map<T>(int count, T Function(int index) job) async {
    final List<T?> results = List<T?>.filled(count, null);
    int next = 0;
    Future<void> work() async {
      while (next < count) {
        final int index = next++;
        results[index] = await _submit(job, index);
      }
    }

    await Future.wait(<Future<void>>[for (int w = 0; w < workers; w++) work()]);
    return <T>[for (final T? result in results) result as T];
  }

  /// Kept apart from [map] so the closure sent to the isolate carries
  /// only [job] and [index], not the results gathered so far.
  static Future<T> _submit<T>(T Function(int index) job, int index) =>
      runIsolateJob(() => job(index));
}
