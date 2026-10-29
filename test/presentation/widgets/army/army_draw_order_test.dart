import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/army/army_draw_order.dart';
import 'package:abyss/presentation/widgets/army/army_piece.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final order = ArmyDrawOrder.backToFront;

  group('ArmyDrawOrder', () {
    test('draws the barracks first and the depot last', () {
      expect(order.first, const BarracksPiece());
      expect(order.last, const DepotPiece());
    });

    test('draws one banner and one squad per type', () {
      for (final type in UnitType.values) {
        expect(order.where((p) => p == BannerPiece(type)), hasLength(1));
        expect(order.where((p) => p == SquadPiece(type)), hasLength(1));
      }
      expect(order, hasLength(2 + 2 * UnitType.values.length));
    });

    test('draws from the back to the front', () {
      final depths = order.map((p) => p.depth).toList();
      expect(depths, orderedEquals([...depths]..sort()));
    });

    test('draws every banner before its own squad', () {
      for (final type in UnitType.values) {
        expect(
          order.indexOf(BannerPiece(type)),
          lessThan(order.indexOf(SquadPiece(type))),
          reason: type.name,
        );
      }
    });

    test('draws the scouts and the harpoonists behind the admirals', () {
      final admirals = order.indexOf(const SquadPiece(UnitType.abyssAdmiral));
      expect(
        order.indexOf(const SquadPiece(UnitType.scout)),
        lessThan(admirals),
      );
      expect(
        order.indexOf(const SquadPiece(UnitType.harpoonist)),
        lessThan(admirals),
      );
    });
  });
}
