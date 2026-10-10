// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get newGameTitle => 'Nueva partida';

  @override
  String get newGameEnterName => 'Escribe tu nombre';

  @override
  String get newGameNameHint => 'Nombre del jugador';

  @override
  String get newGameNameEmpty => 'Escribe un nombre';

  @override
  String newGameNameTooShort(int min) {
    return 'El nombre debe tener al menos $min caracteres';
  }

  @override
  String get newGameTutorial => 'Tutorial';

  @override
  String get newGameTutorialHint =>
      'Una guía te acompaña en los primeros turnos';

  @override
  String get newGameStart => 'Empezar';

  @override
  String get difficultyTitle => 'Dificultad';
}
