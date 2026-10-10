import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../domain/settings/language_choice.dart';

/// The language picked by the player, saved across launches.
///
/// Listeners hear about each real change, so the app can switch language
/// at once.
class LanguageSettings extends ChangeNotifier
    implements ValueListenable<LanguageChoice> {
  static const boxName = 'settings';
  static const _key = 'language';

  final Box<String> _box;
  LanguageChoice _choice;

  /// Settings stored in the already opened [box].
  LanguageSettings(Box<String> box)
    : _box = box,
      _choice = LanguageChoice.fromCode(box.get(_key));

  /// Opens the settings box and reads the saved choice. A box that cannot
  /// be opened is wiped, falling back to [LanguageChoice.automatic].
  static Future<LanguageSettings> open() async {
    Box<String> box;
    try {
      box = await Hive.openBox<String>(boxName);
    } catch (_) {
      await Hive.deleteBoxFromDisk(boxName);
      box = await Hive.openBox<String>(boxName);
    }
    return LanguageSettings(box);
  }

  LanguageChoice get choice => _choice;

  @override
  LanguageChoice get value => _choice;

  /// Switches to [choice] and saves it; [LanguageChoice.automatic] erases
  /// the saved language so the device decides again.
  Future<void> choose(LanguageChoice choice) async {
    if (choice == _choice) return;
    _choice = choice;
    notifyListeners();
    final code = choice.code;
    if (code == null) {
      await _box.delete(_key);
    } else {
      await _box.put(_key, code);
    }
  }
}
