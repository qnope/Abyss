import 'dart:math';

import 'package:abysses/domain/models/message.dart';
import 'package:abysses/domain/models/personality.dart';

class MessageGenerator {
  final Random _random = Random();

  static const Map<MessageType, Map<Archetype, List<String>>> _templates = {
    MessageType.tradeOffer: {
      Archetype.diplomat: [
        'Salutations, {TARGET} ! J\'ai remarqué que tu pourrais bénéficier de nos ressources. Commerce équitable ?',
        'Cher {TARGET}, nos surplus pourraient combler tes besoins. Qu\'en dis-tu ?',
        '{TARGET}, une proposition commerciale avantageuse pour nous deux. Intéressé ?',
      ],
      Archetype.warrior: [
        '{TARGET}, j\'ai des ressources. Tu en veux ? Fais vite.',
        'Écoute {TARGET}, je préfère commercer que piller... pour l\'instant.',
      ],
      Archetype.economist: [
        '{TARGET}, analyse de marché effectuée. Échange mutuellement profitable détecté.',
        'Proposition rationnelle pour {TARGET} : {OFFER} contre ton surplus. Efficace.',
      ],
    },
    MessageType.threat: {
      Archetype.warrior: [
        '{TARGET}, tes défenses pathétiques ne résisteront pas à mes {ARMY_COUNT} troupes. Rends-toi.',
        'Prépare-toi {TARGET}. Mes forces arrivent. {TIME_LIMIT}h pour te rendre.',
      ],
      Archetype.manipulator: [
        '{TARGET}, tu devrais reconsidérer ta position. Ce serait dommage qu\'il arrive quelque chose à ta colonie...',
        'Un petit conseil, {TARGET} : regarde derrière toi.',
      ],
    },
    MessageType.peace: {
      Archetype.diplomat: [
        '{TARGET}, cette guerre nous affaiblit tous les deux. Cessez-le-feu ?',
        'Assez de sang versé, {TARGET}. Parlons paix.',
      ],
      Archetype.defender: [
        '{TARGET}, je propose un pacte de non-agression. La stabilité profite à tous.',
      ],
    },
    MessageType.betrayal: {
      Archetype.manipulator: [
        '{TARGET}, tu es tombé dans mon piège. Bien joué de ma part.',
        'Surprise {TARGET} ! Notre alliance n\'était qu\'un écran de fumée.',
      ],
    },
    MessageType.helpRequest: {
      Archetype.diplomat: [
        '{TARGET}, allié fidèle, j\'ai besoin de ton soutien. Une menace approche.',
        'Urgence {TARGET} ! Peux-tu envoyer des renforts ?',
      ],
      Archetype.defender: [
        '{TARGET}, nos murs tiennent mais pas pour longtemps. Aide-nous.',
      ],
    },
    MessageType.info: {
      Archetype.diplomat: [
        '{TARGET}, information importante : {INFO}. Fais-en bon usage.',
      ],
      Archetype.explorer: [
        '{TARGET}, mes éclaireurs ont repéré quelque chose d\'intéressant : {INFO}.',
      ],
    },
    MessageType.victoryGloat: {
      Archetype.warrior: [
        'Victoire écrasante ! {TARGET}, tu n\'avais aucune chance.',
        '{TARGET}, tes ruines témoignent de ma puissance.',
      ],
      Archetype.conqueror: [
        'Un territoire de plus sous mon contrôle. Merci {TARGET}.',
      ],
    },
    MessageType.apology: {
      Archetype.diplomat: [
        '{TARGET}, cet incident était regrettable. Accepte mes excuses sincères.',
      ],
      Archetype.balanced: [
        '{TARGET}, une erreur de jugement de ma part. Cela ne se reproduira plus.',
      ],
    },
  };

  String generateMessage({
    required MessageType type,
    required Archetype senderArchetype,
    Map<String, String> variables = const {},
  }) {
    // Find templates for this type and archetype
    final typeTemplates = _templates[type];
    if (typeTemplates == null) return 'Message de type inconnu.';

    // Try exact archetype match, then fall back to any available
    var templates = typeTemplates[senderArchetype];
    if (templates == null || templates.isEmpty) {
      templates = typeTemplates.values.expand((t) => t).toList();
    }
    if (templates.isEmpty) return 'Message indisponible.';

    // Pick random template
    var message = templates[_random.nextInt(templates.length)];

    // Replace variables
    for (final entry in variables.entries) {
      message = message.replaceAll('{${entry.key}}', entry.value);
    }

    return message;
  }
}
