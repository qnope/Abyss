import '../../game/defeat_checker.dart';
import '../../raid/noise_rules.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the threats: the raids on the base, the monster families
/// and the waves of the Volcano.
const List<Tip> threatTips = [
  Tip(
    id: TipId.raidAnnounced,
    category: TipCategory.threats,
    title: 'Un raid approche',
    lines: [
      'Ton bruit a attiré des monstres : ils frapperont ta base dans '
          '${NoiseRules.warningTurns} tours.',
      'Recrute des défenseurs, les Harponneurs sont faits pour ça.',
      'Le rempart de la Citadelle corallienne t\'aidera aussi à tenir.',
    ],
    trigger: TipTriggers.raidAnnounced,
  ),
  Tip(
    id: TipId.raidReport,
    category: TipCategory.threats,
    title: 'Le rapport de raid',
    lines: [
      'Après chaque raid, le rapport montre le combat, tes pertes et le '
          'butin.',
      'Un raid perdu pille une partie de tes ressources.',
      'Un raid repoussé efface ta série de défaites.',
    ],
    trigger: TipTriggers.raidFought,
  ),
  Tip(
    id: TipId.lastChance,
    category: TipCategory.threats,
    title: 'Dernière chance',
    lines: [
      'Ta base a perdu ${DefeatChecker.lostRaidsLimit - 1} raids '
          'd\'affilée.',
      'Si le prochain raid est perdu lui aussi, la partie est finie.',
      'Mets tes forces dans la défense : une victoire efface la série.',
    ],
    trigger: TipTriggers.lastChance,
  ),
  Tip(
    id: TipId.monsterFamilies,
    category: TipCategory.threats,
    title: 'Les familles de monstres',
    lines: [
      'Chaque repaire abrite une famille, avec sa propre règle de combat.',
      'Chaque famille a son point faible : une unité qui la contre.',
      'Touche le repaire sur la Carte pour la connaître avant d\'attaquer.',
    ],
    trigger: TipTriggers.monsterFamily,
  ),
  Tip(
    id: TipId.volcanoWave,
    category: TipCategory.threats,
    title: 'La vague du Volcan',
    lines: [
      'Le Volcan envoie ses Krakens reprendre le Noyau.',
      'La vague frappe à la fin du prochain tour : garde une garnison au '
          'Noyau.',
      'Chaque vague perdue fait perdre un niveau au Noyau.',
    ],
    trigger: TipTriggers.volcanoWave,
  ),
];
