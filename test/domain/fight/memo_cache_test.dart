import 'package:abyss/domain/fight/memo_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computes an answer once, null answers included', () {
    final cache = MemoCache<String, int?>();
    int calls = 0;
    int? compute() {
      calls++;
      return null;
    }

    expect(cache.get('a', compute), isNull);
    expect(cache.get('a', compute), isNull);
    expect(calls, 1);
  });

  test('forgets the least recently used answer beyond its capacity', () {
    final cache = MemoCache<String, int>(capacity: 2);
    int calls = 0;
    int compute() => ++calls;

    cache.get('a', compute);
    cache.get('b', compute);
    cache.get('a', compute);
    cache.get('c', compute);

    expect(cache.length, 2);
    expect(cache.get('a', compute), 1);
    expect(cache.get('b', compute), 4);
  });
}
