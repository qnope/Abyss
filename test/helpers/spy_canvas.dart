import 'dart:ui';

/// A canvas drawing nothing, reporting each call made on it to [onCall]
/// with its positional arguments.
class SpyCanvas implements Canvas {
  final void Function(Symbol method, List<dynamic> args) onCall;

  SpyCanvas(this.onCall);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      onCall(invocation.memberName, invocation.positionalArguments);
}
