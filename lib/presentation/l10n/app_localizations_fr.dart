// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get newGameTitle => 'Nouvelle Partie';

  @override
  String get newGameEnterName => 'Entrez votre nom';

  @override
  String get newGameNameHint => 'Nom du joueur';

  @override
  String get newGameNameEmpty => 'Veuillez entrer un nom';

  @override
  String newGameNameTooShort(int min) {
    return 'Le nom doit contenir au moins $min caractères';
  }

  @override
  String get newGameTutorial => 'Tutoriel';

  @override
  String get newGameTutorialHint =>
      'Un guide t\'accompagne sur les premiers tours';

  @override
  String get newGameStart => 'Commencer';

  @override
  String get difficultyTitle => 'Difficulté';
}
