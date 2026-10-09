import 'dart:isolate';

/// Runs [job] on a fresh isolate and brings its result back.
///
/// The job and what it captures are copied over, so it must only reach
/// plain data: no open file, port or stream.
Future<T> runIsolateJob<T>(T Function() job) => Isolate.run(job);
