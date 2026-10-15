import 'package:flutter/widgets.dart';

import 'ambience_clock.dart';

/// Builds the widget a [AmbienceClockScope] wraps, with its clock.
typedef AmbienceClockWidgetBuilder =
    Widget Function(BuildContext context, AmbienceClock clock);

/// Owns the [AmbienceClock] of one layer and hands it to [builder].
///
/// The clock runs while [animate] is true and the platform allows
/// animations, freezes otherwise, and pauses under a disabled TickerMode
/// (a route covering the screen). Descendants can also reach it through
/// [maybeOf], so a whole list shares a single clock.
class AmbienceClockScope extends StatefulWidget {
  final AmbienceClockWidgetBuilder builder;
  final bool animate;

  const AmbienceClockScope({
    super.key,
    required this.builder,
    this.animate = true,
  });

  /// The clock of the nearest scope above [context], if any.
  static AmbienceClock? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ClockProvider>()?.clock;

  @override
  State<AmbienceClockScope> createState() => _AmbienceClockScopeState();
}

class _AmbienceClockScopeState extends State<AmbienceClockScope>
    with SingleTickerProviderStateMixin {
  late final AmbienceClock _clock = AmbienceClock(vsync: this);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AmbienceClockScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Runs the clock while motion is welcome, freezes it otherwise.
  void _sync() {
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    widget.animate && !reduced ? _clock.start() : _clock.stop();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ClockProvider(
    clock: _clock,
    child: Builder(builder: (context) => widget.builder(context, _clock)),
  );
}

/// Shares the clock below the scope; the clock itself never changes.
class _ClockProvider extends InheritedWidget {
  final AmbienceClock clock;

  const _ClockProvider({required this.clock, required super.child});

  @override
  bool updateShouldNotify(_ClockProvider oldWidget) => clock != oldWidget.clock;
}
