import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the map: what the exploration reveals, and the way down.
const List<Tip> mapTips = [
  Tip(
    id: TipId.lair,
    category: TipCategory.map,
    title: 'Les repaires',
    lines: [
      'Sur la Carte, un repaire de monstres garde sa case : attaque-le avec '
          'ton armée.',
      'Vaincus, les monstres laissent leur butin, mais chaque combat fait '
          'du bruit.',
      'Regarde leur nombre avant de choisir tes unités.',
    ],
    trigger: TipTriggers.lair,
  ),
  Tip(
    id: TipId.chestAndRuins,
    category: TipCategory.map,
    title: 'Coffres et ruines',
    lines: [
      'Un coffre ou des ruines cachent des ressources.',
      'Touche la case sur la Carte pour les fouiller : c\'est sans danger '
          'et sans bruit.',
    ],
    trigger: TipTriggers.chestOrRuins,
  ),
  Tip(
    id: TipId.transitionBase,
    category: TipCategory.map,
    title: 'Les bases de transition',
    lines: [
      'Une base gardée, sur la Carte, mène vers les profondeurs.',
      'Prise d\'assaut, elle te rapporte des perles à chaque tour.',
      'Elle ouvre aussi la route du niveau suivant.',
    ],
    trigger: TipTriggers.transitionBase,
  ),
  Tip(
    id: TipId.descent,
    category: TipCategory.map,
    title: 'La descente',
    lines: [
      'Ton Module de descente envoie des unités au niveau inférieur, par '
          'la Faille.',
      'Attention : une unité descendue ne remonte plus.',
      'En bas t\'attendent d\'autres repaires, et la route du Noyau.',
    ],
    trigger: TipTriggers.descent,
  ),
];
