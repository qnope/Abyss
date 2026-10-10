import 'package:abyss/domain/game/game.dart';
import 'package:abyss/domain/objective/objective_catalog.dart';
import 'package:abyss/domain/objective/objective_chapter.dart';
import 'package:abyss/domain/objective/objective_id.dart';
import 'package:abyss/presentation/widgets/objective/objective_row.dart';
import 'package:abyss/presentation/widgets/objective/objectives_sheet.dart';
import 'package:abyss/presentation/widgets/resource/resource_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_svg_helper.dart';
import 'objective_widget_helpers.dart';

Future<void> _show(WidgetTester tester, Game game) async {
  tester.view.physicalSize = const Size(800, 8000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    objectiveApp(ObjectivesSheetBody(game: game, player: game.humanPlayer)),
  );
}

ObjectiveRow _row(WidgetTester tester, ObjectiveId id) => tester.widget(
  find.ancestor(
    of: find.text(ObjectiveCatalog.byId(id).title),
    matching: find.byType(ObjectiveRow),
  ),
);

void main() {
  group('ObjectivesSheetBody', () {
    setUp(mockSvgAssets);
    tearDown(clearSvgMocks);

    testWidgets('lists the six chapters in order', (tester) async {
      await _show(tester, gameWithCompleted(0));

      final titles = [
        for (final chapter in ObjectiveChapter.values)
          '${chapter.index + 1}. ${chapter.title}',
      ];
      final tops = [
        for (final title in titles) tester.getTopLeft(find.text(title)).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
    });

    testWidgets('lists every objective of the catalog', (tester) async {
      await _show(tester, gameWithCompleted(0));

      expect(
        find.byType(ObjectiveRow),
        findsNWidgets(ObjectiveId.values.length),
      );
    });

    testWidgets('marks objectives done, current and to do', (tester) async {
      await _show(tester, gameWithCompleted(2));

      expect(_row(tester, ObjectiveId.hqLevel1).status, ObjectiveStatus.done);
      expect(_row(tester, ObjectiveId.algaeFarm).status, ObjectiveStatus.done);
      expect(_row(tester, ObjectiveId.mines).status, ObjectiveStatus.current);
      expect(_row(tester, ObjectiveId.solarPanel).status, ObjectiveStatus.toDo);
      expect(
        _row(tester, ObjectiveId.kernelLevel10).status,
        ObjectiveStatus.toDo,
      );
    });

    testWidgets('shows the progress of the current objective only', (
      tester,
    ) async {
      await _show(tester, gameWithCompleted(2));

      expect(_row(tester, ObjectiveId.mines).progress.toString(), '0/2');
      expect(_row(tester, ObjectiveId.solarPanel).progress, isNull);
      expect(find.text('0/2'), findsOneWidget);
    });

    testWidgets('shows the reward of each objective with its icons', (
      tester,
    ) async {
      await _show(tester, gameWithCompleted(0));

      final rewarded = ObjectiveCatalog.all.fold<int>(
        0,
        (sum, objective) => sum + objective.reward.length,
      );
      expect(find.byType(ResourceIcon), findsNWidgets(rewarded));
      expect(find.text('+30'), findsNWidgets(9));
    });

    testWidgets('lists the active temporary objectives first', (tester) async {
      final game = gameWithCompleted(0)..turn = 12;
      layWreck(game);

      await _show(tester, game);

      final wreck = find.text("Fouille l'épave d'ici la fin du tour 17");
      expect(wreck, findsOneWidget);
      expect(
        tester.getTopLeft(wreck).dy,
        lessThan(tester.getTopLeft(find.text('1. Installation')).dy),
      );
    });

    testWidgets('has no event section without temporary objectives', (
      tester,
    ) async {
      await _show(tester, gameWithCompleted(0));

      expect(find.text("Objectifs d'événement"), findsNothing);
    });
  });
}
