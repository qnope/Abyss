import 'package:flutter/widgets.dart';

import '../../data/language_settings.dart';

/// Makes the player's [LanguageSettings] reachable from every screen
/// below it, without passing them through each constructor.
class LanguageScope extends InheritedNotifier<LanguageSettings> {
  const LanguageScope({
    super.key,
    required LanguageSettings settings,
    required super.child,
  }) : super(notifier: settings);

  /// The settings above [context], or null when none are (as in widget
  /// tests with a bare app). The caller rebuilds when the language changes.
  static LanguageSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LanguageScope>()?.notifier;
}
