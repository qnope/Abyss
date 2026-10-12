import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/fight/assault/assault_target.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/domain/objective/guide/guide_message.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/extensions/guide_campaign_texts.dart';
import 'package:abyss/presentation/extensions/guide_message_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/l10n_fixtures.dart';

void main() {
  const faille = AssaultTarget.faille;
  const kernel = AssaultTarget.kernel;

  test('the admiral, its barracks and its descent', () {
    expect(
      const GuideAdmiralNeedsBarracks(faille, 2).text(fr),
      'Pour prendre une Faille, il faut un Amiral. Monte la Caserne au '
      'niveau 2.',
    );
    expect(
      const GuideAdmiralToRecruit(faille).text(fr),
      'Recrute un Amiral : il ne se bat pas, mais sans lui la Faille ne se '
      'prend pas.',
    );
    expect(
      const GuideAdmiralToSend(kernel, 3).text(fr),
      allOf(contains('le Noyau'), contains('niveau 3')),
    );
    expect(
      const GuideAdmiralNeedsBarracks(AssaultTarget.cheminee, 2).text(en),
      'To take a Vent, you need an Admiral. Raise the Barracks to level 2.',
    );
    expect(const GuideAdmiralToRecruit(kernel).text(es), contains('Núcleo'));
  });

  test('the post to find, then to assault', () {
    expect(
      const GuidePostToFind(faille).text(fr),
      'Explore la Carte pour trouver une Faille, mais n\'oublie pas de '
      'continuer à améliorer tes bâtiments et ton armée !',
    );
    expect(
      const GuidePostToFind(AssaultTarget.cheminee).text(fr),
      'Explore la Carte au niveau 2 pour trouver une Cheminée, mais '
      'n\'oublie pas de continuer à améliorer tes bâtiments et ton armée !',
    );
    expect(
      const GuidePostToFind(kernel).text(fr),
      'Explore la Carte au niveau 3 pour trouver le Noyau, mais n\'oublie '
      'pas de continuer à améliorer tes bâtiments et ton armée !',
    );
    expect(
      const GuidePostToFind(kernel).text(en),
      'Explore the Map on level 3 to find the Core, but don\'t forget to '
      'keep upgrading your buildings and your army!',
    );
    expect(
      const GuidePostToFind(kernel).text(es),
      'Explora el Mapa en el nivel 3 para encontrar el Núcleo, pero no '
      'olvides seguir mejorando tus edificios y tu ejército.',
    );
    expect(
      const GuidePostToFind(AssaultTarget.cheminee).text(en),
      'Explore the Map on level 2 to find a Vent, but don\'t forget to keep '
      'upgrading your buildings and your army!',
    );
    expect(
      const GuidePostToFind(AssaultTarget.cheminee).text(es),
      'Explora el Mapa en el nivel 2 para encontrar una Chimenea, pero no '
      'olvides seguir mejorando tus edificios y tu ejército.',
    );
    expect(
      const GuidePostAssault(faille, harpoonists: 14).text(fr),
      'Une Faille ! Ton Amiral doit survivre : couvre-le de Gardiens. '
      'Envoie-le avec au moins 14 Harponneurs : tu gagnes 19 fois sur 20.',
    );
    expect(
      const GuidePostAssault(faille).text(fr),
      'Une Faille ! Ton Amiral doit survivre : couvre-le de Gardiens.',
    );
    expect(
      const GuidePostAssault(kernel, harpoonists: 0).text(en),
      'The Core! Your Admiral must survive: cover him with Guardians. '
      'Your escort is enough: you win 19 times out of 20.',
    );
    expect(
      const GuidePostAssault(faille, harpoonists: 1).text(es),
      contains('al menos 1 Arponero:'),
    );
  });

  test('a victory where the admiral fell', () {
    expect(
      const GuideAdmiralFell(faille).text(fr),
      "Victoire, mais ton Amiral est tombé : la Faille n'est pas prise. "
      'Couvre-le de Gardiens et recommence.',
    );
    expect(
      const GuideAdmiralFell(kernel).text(fr),
      contains("n'est pas pris."),
    );
    expect(const GuideAdmiralFell(kernel).text(en), contains('the Core'));
  });

  test('the passages and the posts held', () {
    expect(
      const GuidePassageNeedsHq(BuildingType.descentModule, 5).text(fr),
      startsWith('Le Module de descente demande le QG 5'),
    );
    expect(
      const GuidePassageNeedsHq(BuildingType.pressureCapsule, 8).text(en),
      startsWith('The Pressure Capsule needs Headquarters level 8'),
    );
    expect(
      const GuidePostUndefended(TransitionBaseType.faille, 2).text(fr),
      "Ta Faille n'est gardée que par tes unités du niveau 2. Si elle tombe, "
      "ton Module est détruit et tes unités d'en bas sont perdues.",
    );
    expect(
      const GuidePostUndefended(TransitionBaseType.cheminee, 3).text(es),
      contains('Chimenea'),
    );
  });

  test('says nothing of a message of the tutorial', () {
    expect(const GuideGoalMet().campaignText(fr), isEmpty);
  });

  test('a kraken wave on the kernel', () {
    expect(
      const GuideKernelWave(4, needed: 12).text(fr),
      'Les Krakens viennent reprendre le Noyau ! Mets au moins 12 unités en '
      'garnison avant la fin du tour, sinon le Noyau perd un niveau.',
    );
    expect(const GuideKernelWave(40).text(en), startsWith('40 Krakens'));
  });

  test('a lesson for each step of the rift, the chimney and the kernel', () {
    const steps = [
      ObjectiveId.descentModule,
      ObjectiveId.descendLevel2,
      ObjectiveId.hqLevel8,
      ObjectiveId.pressureCapsule,
      ObjectiveId.descendLevel3,
      ObjectiveId.hqLevel10,
      ObjectiveId.kernelLevel1,
    ];
    for (final l10n in [fr, en, es]) {
      for (final id in steps) {
        expect(GuideLesson(id).text(l10n), isNotEmpty, reason: id.name);
      }
    }
    expect(
      const GuideLesson(ObjectiveId.descendLevel2).text(fr),
      'Envoie des unités au niveau 2 par la Faille. Attention, elles ne '
      'remontent pas.',
    );
  });
}
