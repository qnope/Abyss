import 'package:abyss/domain/game/game_status.dart';
import 'package:abyss/presentation/screens/game/defeat_screen.dart';
import 'package:abyss/presentation/screens/game/game_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_game_repository.dart';
import '../../../helpers/load_game_harness.dart';
import '../../../helpers/test_svg_helper.dart';

void main() {
  late FakeGameRepository repository;

  setUp(() {
    mockSvgAssets();
    repository = FakeGameRepository();
  });
  tearDown(clearSvgMocks);

  Future<void> openDeleteDialog(WidgetTester tester, int index) async {
    await tester.tap(find.byTooltip('Options').at(index));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks before deleting a game', (tester) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));

    await openDeleteDialog(tester, 0);

    expect(find.text('Supprimer la partie ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
  });

  testWidgets('deletes only the game whose menu was used', (tester) async {
    repository
      ..addGame(savedGame('Alice', hoursAgo: 1))
      ..addGame(savedGame('Bob', hoursAgo: 2));
    await tester.pumpWidget(loadGameApp(repository));

    await openDeleteDialog(tester, 1);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);
    expect(repository.loadAll().single.humanPlayer.name, 'Alice');
  });

  testWidgets('shows the empty state once the last game is deleted', (
    tester,
  ) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));

    await openDeleteDialog(tester, 0);
    await tester.tap(find.text('Supprimer'));
    await tester.pumpAndSettle();

    expect(find.text('Aucune partie sauvegardée'), findsOneWidget);
  });

  testWidgets('cancelling keeps the game', (tester) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));

    await openDeleteDialog(tester, 0);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(repository.loadAll(), hasLength(1));
  });

  testWidgets('a lost game reopens on the defeat screen', (tester) async {
    repository.addGame(
      savedGame('Alice', status: GameStatus.defeat, turn: 27),
    );
    await tester.pumpWidget(loadGameApp(repository));
    expect(find.text('Tombée au tour 26 · Surface · Normal'), findsOneWidget);

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(find.byType(DefeatScreen), findsOneWidget);
  });

  testWidgets('a game in progress reopens on the game screen', (
    tester,
  ) async {
    repository.addGame(savedGame('Alice'));
    await tester.pumpWidget(loadGameApp(repository));

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    expect(find.byType(GameScreen), findsOneWidget);
  });
}
