import 'package:abyss/domain/fight/assault/assault_chance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rates 90 % and more as high', () {
    expect(const AssaultChance(wins: 20, rehearsals: 20).rating,
        AssaultRating.high);
    expect(const AssaultChance(wins: 18, rehearsals: 20).rating,
        AssaultRating.high);
  });

  test('rates 50 % to 90 % as risky', () {
    expect(const AssaultChance(wins: 17, rehearsals: 20).rating,
        AssaultRating.risky);
    expect(const AssaultChance(wins: 10, rehearsals: 20).rating,
        AssaultRating.risky);
  });

  test('rates under 50 % as low', () {
    expect(const AssaultChance(wins: 9, rehearsals: 20).rating,
        AssaultRating.low);
  });

  test('none is never rehearsed, rated low', () {
    const chance = AssaultChance.none;

    expect(chance.wins, 0);
    expect(chance.rehearsals, 0);
    expect(chance.rate, 0);
    expect(chance.rating, AssaultRating.low);
  });

  test('rate is the share of rehearsals won', () {
    expect(const AssaultChance(wins: 19, rehearsals: 20).rate, 0.95);
  });

  test('equal when the counts are', () {
    expect(const AssaultChance(wins: 3, rehearsals: 20),
        const AssaultChance(wins: 3, rehearsals: 20));
    expect(const AssaultChance(wins: 3, rehearsals: 20).hashCode,
        const AssaultChance(wins: 3, rehearsals: 20).hashCode);
    expect(const AssaultChance(wins: 3, rehearsals: 20),
        isNot(const AssaultChance(wins: 4, rehearsals: 20)));
  });

  test('reads as wins over rehearsals', () {
    expect(const AssaultChance(wins: 19, rehearsals: 20).toString(),
        'AssaultChance(19/20)');
  });
}
