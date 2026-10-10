import 'package:abyss/presentation/extensions/relative_date_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 10, 15, 30);

  String format(DateTime date) => date.relativeTo(now);

  group('within the hour', () {
    test('less than a minute ago is just now', () {
      expect(format(now), "à l'instant");
      expect(format(now.subtract(const Duration(seconds: 59))),
          "à l'instant");
    });

    test('a date slightly in the future is just now', () {
      expect(format(now.add(const Duration(minutes: 3))), "à l'instant");
    });

    test('counts the whole minutes elapsed', () {
      expect(format(now.subtract(const Duration(minutes: 1))),
          'il y a 1 min');
      expect(format(now.subtract(const Duration(minutes: 5, seconds: 50))),
          'il y a 5 min');
      expect(format(now.subtract(const Duration(minutes: 59))),
          'il y a 59 min');
    });

    test('minutes are counted across midnight', () {
      final DateTime justAfterMidnight = DateTime(2026, 10, 10, 0, 10);
      expect(DateTime(2026, 10, 9, 23, 50).relativeTo(justAfterMidnight),
          'il y a 20 min');
    });
  });

  group('earlier today', () {
    test('counts the whole hours elapsed', () {
      expect(format(now.subtract(const Duration(hours: 1))), 'il y a 1 h');
      expect(format(now.subtract(const Duration(hours: 2, minutes: 59))),
          'il y a 2 h');
      expect(format(DateTime(2026, 10, 10)), 'il y a 15 h');
    });
  });

  group('yesterday', () {
    test('any time of the previous day is yesterday', () {
      expect(format(DateTime(2026, 10, 9, 23, 59)), 'hier');
      expect(format(DateTime(2026, 10, 9)), 'hier');
    });

    test('yesterday crosses months and years', () {
      expect(DateTime(2026, 9, 30, 20).relativeTo(DateTime(2026, 10, 1, 8)),
          'hier');
      expect(
          DateTime(2025, 12, 31, 20).relativeTo(DateTime(2026, 1, 1, 8)),
          'hier');
    });
  });

  group('older dates', () {
    test('shows the day and short month of this year', () {
      expect(format(DateTime(2026, 10, 8, 12)), '8 oct.');
      expect(format(DateTime(2026, 1, 1)), '1 janv.');
    });

    test('adds the year for another year', () {
      expect(format(DateTime(2025, 10, 5)), '5 oct. 2025');
    });

    test('uses the french short month names', () {
      const List<String> months = [
        'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
        'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
      ];
      for (var month = 1; month <= 12; month++) {
        expect(format(DateTime(2024, month, 3)), '3 ${months[month - 1]} 2024');
      }
    });
  });

  test('a utc date is compared in local time', () {
    final DateTime utc = now.subtract(const Duration(minutes: 5)).toUtc();
    expect(format(utc), 'il y a 5 min');
  });
}
