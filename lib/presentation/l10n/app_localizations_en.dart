// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newGameTitle => 'New Game';

  @override
  String get newGameEnterName => 'Enter your name';

  @override
  String get newGameNameHint => 'Player name';

  @override
  String get newGameNameEmpty => 'Please enter a name';

  @override
  String newGameNameTooShort(int min) {
    return 'The name must be at least $min characters long';
  }

  @override
  String get newGameTutorial => 'Tutorial';

  @override
  String get newGameTutorialHint => 'A guide walks you through the first turns';

  @override
  String get newGameStart => 'Start';

  @override
  String get difficultyTitle => 'Difficulty';
}
