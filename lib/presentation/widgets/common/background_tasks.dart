import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Runs costly tasks one at a time, never within the frame asking: each
/// in a turn of the event loop of its own, [spacing] after the last, out
/// of any zone faking time (a widget test's).
///
/// On the web, rasterizing a bitmap holds the main thread: one at a time,
/// a frame apart, the frames go on between them.
abstract final class BackgroundTasks {
  /// The wait before each task: a frame on the web.
  static const spacing =
      kIsWeb ? Duration(milliseconds: 16) : Duration.zero;

  static final _queue = Queue<void Function()>();

  /// Queues [task], run after those queued before it.
  static void run(void Function() task) {
    _queue.add(task);
    if (_queue.length == 1) _next();
  }

  static void _next() => Zone.root.createTimer(spacing, () {
        final task = _queue.first;
        try {
          task();
        } catch (error, stack) {
          FlutterError.reportError(
              FlutterErrorDetails(exception: error, stack: stack));
        } finally {
          _queue.removeFirst();
          if (_queue.isNotEmpty) _next();
        }
      });
}
