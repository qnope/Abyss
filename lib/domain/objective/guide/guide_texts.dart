import '../objective_id.dart';

/// What the guide of the tutorial, the octopus archivist, says: one lesson
/// per objective of the tutorial, then a word for each situation that
/// holds an objective back.
abstract final class GuideTexts {
  /// The lesson of the tutorial objective [id], `null` past the tutorial.
  static String? lessonOf(ObjectiveId id) => _lessons[id];

  static const _lessons = {
    ObjectiveId.hqLevel1:
        'Bienvenue dans les abysses ! Touche le QG pour lancer ton premier '
        'chantier : un seul par tour pour commencer. Puis appuie sur '
        '« Tour suivant ».',
    ObjectiveId.algaeFarm:
        'Bravo pour ce premier chantier ! Les algues nourrissent ton armée : '
        'chaque unité en mange à chaque tour. Construis la Ferme d\'algues.',
    ObjectiveId.mines:
        'Le corail et le minerai paient presque tout. Construis la Mine de '
        'corail puis l\'Extracteur de minerai, un par tour. Regarde bien : '
        'chaque niveau coûte plus cher que le précédent.',
    ObjectiveId.solarPanel:
        'L\'Extracteur consomme de l\'énergie, et la Caserne en consommera '
        'aussi. Sans énergie, ils s\'arrêtent. Construis le Panneau solaire.',
    ObjectiveId.hqLevel2:
        'Le QG niveau 2 débloque la Caserne et le Laboratoire. Mais chaque '
        'chantier fait du bruit : surveille la jauge en haut de l\'écran, '
        'elle attire les monstres.',
    ObjectiveId.barracksAndScouts:
        'Construis la Caserne, puis recrute 2 Éclaireurs dans l\'onglet '
        'Armée. Chaque unité mange des algues à chaque tour, et chaque '
        'recrue fait monter le bruit.',
    ObjectiveId.explore:
        'Autour de ta base, tout est dans le brouillard. Sur la Carte, '
        'envoie un Éclaireur sur une case voisine : tu y trouveras des '
        'repaires de monstres de différentes familles, et parfois des coffres.',
    ObjectiveId.laboratoryAndResearch:
        'Construis le Laboratoire, ouvre une branche dans l\'onglet Tech et '
        'lance une recherche. Une seule recherche par tour, et certains '
        'choix sont définitifs : prends le temps de lire.',
    ObjectiveId.firstRaid:
        'Le bruit finit toujours par attirer un raid, annoncé 2 tours à '
        'l\'avance. Recrute des Harponneurs pour défendre ta base. Plus '
        'tard, le rempart de la Citadelle t\'aidera aussi.',
  };

  static const goalMet =
      'Bravo, c\'est fait ! Termine le tour pour valider l\'objectif et '
      'toucher ta récompense.';

  static const worksiteTaken =
      'Ton chantier du tour est déjà pris. Termine le tour : tu '
      'construiras la suite au prochain.';

  static const alreadyRecruited =
      'Tu as déjà recruté ces unités ce tour. Termine le tour pour en '
      'recruter d\'autres.';

  static const exploring =
      'Ton Éclaireur est en route. Termine le tour pour découvrir ce que '
      'cache la case.';

  static String storm(int untilTurn) =>
      'Une tempête ferme l\'exploration jusqu\'à la fin du tour $untilTurn. '
      'Patiente : l\'objectif t\'attend, termine le tour.';

  static String wreckWithoutBarracks(int untilTurn) =>
      'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour '
      '$untilTurn. Il faut un Éclaireur pour l\'atteindre, donc une '
      'Caserne : continue ton objectif, elle viendra.';

  static String wreckWithoutScout(int untilTurn) =>
      'Une épave a coulé près de ta base, visible jusqu\'à la fin du tour '
      '$untilTurn. Recrute un Éclaireur dans l\'onglet Armée pour aller la '
      'fouiller.';

  static String raidIncoming(int arrivalTurn) =>
      'Un raid frappera ta base à la fin du tour $arrivalTurn ! Recrute des '
      'Harponneurs dans l\'onglet Armée pour le repousser.';
}
