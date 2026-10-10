import '../../event/event_rules.dart';
import '../../event/random_event_type.dart';
import 'tip.dart';
import 'tip_category.dart';
import 'tip_id.dart';
import 'tip_triggers.dart';

/// The tips of the random events: one for the principle, then one for
/// each event at its first draw.
abstract final class EventTips {
  /// The principle first, then one tip per event.
  static final List<Tip> all = [
    const Tip(
      id: TipId.events,
      category: TipCategory.events,
      title: 'Les événements',
      lines: [
        'Tous les ${EventRules.minGap} à ${EventRules.maxGap} tours, un '
            'événement secoue les abysses.',
        'Tu as le tour suivant pour choisir ta réponse sur sa carte.',
        'Sans choix de ta part, l\'option prudente s\'applique d\'office.',
      ],
      trigger: TipTriggers.event,
    ),
    for (final type in RandomEventType.values) _tipOf(type),
  ];

  /// The tip of the event [type].
  static TipId idOf(RandomEventType type) => switch (type) {
    RandomEventType.warmCurrent => TipId.warmCurrent,
    RandomEventType.wreck => TipId.wreck,
    RandomEventType.predators => TipId.predators,
    RandomEventType.storm => TipId.storm,
    RandomEventType.survivors => TipId.survivors,
    RandomEventType.caravan => TipId.caravan,
    RandomEventType.coldCurrent => TipId.coldCurrent,
  };

  static Tip _tipOf(RandomEventType type) {
    final (String title, List<String> lines) = _texts[type]!;
    return Tip(
      id: idOf(type),
      category: TipCategory.events,
      title: title,
      lines: lines,
      trigger: TipTriggers.drawn(type),
    );
  }

  static const _texts = {
    RandomEventType.warmCurrent: (
      'Courant chaud',
      [
        'Un courant chaud dope ta production pendant '
            '${EventRules.effectTurns} tours.',
        'Mais son remous fait du bruit à chaque tour.',
        'Exploite-le si tes défenses sont prêtes à recevoir un raid.',
      ],
    ),
    RandomEventType.wreck: (
      'Épave',
      [
        'Un galion englouti reste ${EventRules.wreckTurns} tours au bord de '
            'la zone explorée.',
        'Explore sa case avec un Éclaireur, puis fouille-la pour son butin.',
        'La fouille fait du bruit (+${EventRules.wreckNoise}) : choisis ton '
            'moment.',
      ],
    ),
    RandomEventType.predators: (
      'Banc de prédateurs',
      [
        'Un grand requin et son banc rôdent autour de ta base.',
        'Affronte-les pour leur butin, ou cède des algues pour les éloigner.',
        'Perdre contre eux ne met jamais fin à la partie.',
      ],
    ),
    RandomEventType.storm: (
      'Tempête',
      [
        'La tempête ferme l\'exploration pendant ${EventRules.stormTurns} '
            'tours.',
        'En échange, elle couvre ton bruit : la jauge baisse de '
            '${EventRules.stormNoiseRelief}.',
      ],
    ),
    RandomEventType.survivors: (
      'Survivants',
      [
        'Une capsule échouée abrite des survivants.',
        'Accueillis, ils rejoignent ta base comme Harponneurs.',
        'Comme toute ton armée, ils mangent des algues à chaque tour.',
      ],
    ),
    RandomEventType.caravan: (
      'Caravane de tortues',
      [
        'Une caravane de tortues passe près de ta base.',
        'Son crabe marchand échange ta ressource la plus abondante contre la '
            'plus rare.',
      ],
    ),
    RandomEventType.coldCurrent: (
      'Courant froid',
      [
        'Un courant froid ralentit tes algues pendant '
            '${EventRules.effectTurns} tours.',
        'Chauffer les serres coûte de l\'énergie, mais sauve la récolte.',
        'Sans algues, ton armée ne tient pas : surveille ton stock.',
      ],
    ),
  };
}
