import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/faction/faction.dart';
import 'package:abyss/domain/faction/faction_personality.dart';
import 'package:abyss/domain/faction/post_defence.dart';
import 'package:abyss/domain/map/transition_base.dart';
import 'package:abyss/domain/map/transition_base_type.dart';
import 'package:abyss/presentation/l10n/abyss_locale.dart';
import 'package:abyss/presentation/widgets/faction/faction_emblem.dart';
import 'package:abyss/presentation/widgets/map/post_defence_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/localized_app.dart';

final TransitionBase _faille = TransitionBase(
  type: TransitionBaseType.faille,
  name: 'F',
  capturedBy: 'h',
);
final TransitionBase _cheminee = TransitionBase(
  type: TransitionBaseType.cheminee,
  name: 'C',
  capturedBy: 'h',
);

const PostThreat _horde = PostThreat(
  faction: Faction(FactionPersonality.murenaHorde),
  units: 35,
  reportTurn: 21,
  turnsAgo: 2,
);

PostDefence _defence({
  PostThreat? threat,
  BuildingType passage = BuildingType.descentModule,
  int unitsBelow = 0,
  int reinforcements = 0,
}) => PostDefence(
  threat: threat,
  passage: passage,
  unitsBelow: unitsBelow,
  reinforcements: reinforcements,
);

Future<void> _pump(
  WidgetTester t,
  PostDefence defence, {
  TransitionBase? post,
  Locale locale = AbyssLocale.fr,
}) => t.pumpWidget(
  localizedApp(
    Scaffold(body: PostDefencePanel(post: post ?? _faille, defence: defence)),
    locale: locale,
  ),
);

void main() {
  testWidgets('shows the known threat with its emblem', (t) async {
    await _pump(t, _defence(threat: _horde));

    expect(
      find.text('La Horde des Murènes : 35 combattants (rapport du tour 21)'),
      findsOneWidget,
    );
    final emblem = t.widget<FactionEmblem>(find.byType(FactionEmblem));
    expect(emblem.personality, FactionPersonality.murenaHorde);
  });

  testWidgets('shows no threat line when none is known', (t) async {
    await _pump(t, _defence());

    expect(find.byType(FactionEmblem), findsNothing);
    expect(find.textContaining('combattant'), findsNothing);
  });

  testWidgets('lists everything lost when a Faille falls', (t) async {
    await _pump(t, _defence(unitsBelow: 12, reinforcements: 3));

    expect(find.text('Si la Faille tombe'), findsOneWidget);
    expect(find.text('Module de descente détruit'), findsOneWidget);
    expect(find.text('12 unités du niveau 2 perdues'), findsOneWidget);
    expect(find.text('3 renforts en route annulés'), findsOneWidget);
    expect(
      find.text('Les factions attaquent les postes sans prévenir.'),
      findsOneWidget,
    );
  });

  testWidgets('leaves out the units and reinforcements at zero', (t) async {
    await _pump(t, _defence());

    expect(find.text('Module de descente détruit'), findsOneWidget);
    expect(find.textContaining('perdue'), findsNothing);
    expect(find.textContaining('annulé'), findsNothing);
  });

  testWidgets('names the Cheminée and its capsule', (t) async {
    await _pump(
      t,
      _defence(passage: BuildingType.pressureCapsule, unitsBelow: 1),
      post: _cheminee,
    );

    expect(find.text('Si la Cheminée tombe'), findsOneWidget);
    expect(find.text('Capsule pressurisée détruite'), findsOneWidget);
    expect(find.text('1 unité du niveau 3 perdue'), findsOneWidget);
  });

  testWidgets('speaks English', (t) async {
    await _pump(
      t,
      _defence(threat: _horde, reinforcements: 1),
      locale: AbyssLocale.en,
    );

    expect(find.text('If the Rift falls'), findsOneWidget);
    expect(find.text('Descent Module destroyed'), findsOneWidget);
    expect(find.text('1 reinforcement on the way cancelled'), findsOneWidget);
  });
}
