import '../../raid/noise_rules.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the base: the noise, the building sites, the research
/// choices.
const List<Tip> baseTips = [
  Tip(
    id: TipId.noiseGauge,
    category: TipCategory.base,
    title: 'La jauge de bruit',
    lines: [
      'Chaque chantier, chaque recrue et chaque exploration font du bruit, '
          'et ta base en fait un peu à chaque tour.',
      'Quand la jauge atteint ${NoiseRules.threshold}, les monstres '
          'l\'entendent : un raid est annoncé.',
    ],
    trigger: TipTriggers.noise,
  ),
  Tip(
    id: TipId.worksites,
    category: TipCategory.base,
    title: 'Deux chantiers par tour',
    lines: [
      'Ton QG niveau 5 ouvre un deuxième chantier : deux bâtiments montent '
          'à chaque tour.',
      'Le QG niveau 10 en ouvrira un troisième. La recherche, elle, reste '
          'à une par tour.',
    ],
    trigger: TipTriggers.worksites,
  ),
  Tip(
    id: TipId.techChoice,
    category: TipCategory.base,
    title: 'Les choix de la recherche',
    lines: [
      'Le prochain nœud de ta branche est un choix entre deux options.',
      'Ce choix est définitif : l\'autre option restera fermée pour toute '
          'la partie.',
      'Prends le temps de lire les deux avant de lancer la recherche.',
    ],
    trigger: TipTriggers.techChoice,
  ),
];
