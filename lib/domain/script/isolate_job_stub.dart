/// Runs [job] inline: there is no isolate on the web.
Future<T> runIsolateJob<T>(T Function() job) async => job();
