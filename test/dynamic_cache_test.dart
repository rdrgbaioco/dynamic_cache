import 'dart:math';

import 'package:dynamic_cache/dynamic_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> names;
  const instance = DynamicCache.instance;

  setUp(() {
    names = const [
      'John',
      'Jane',
      'Jack',
      'Jill',
      'Jack',
      'Annie',
      'Bill',
    ];
  });

  test('Add and remove items from memory cache', () async {
    instance.add(
      'names',
      names,
      expiration: const Duration(seconds: 5),
    );

    final result = instance.get<List<String>>('names');

    expect(
      result,
      isA<List<String>>().having((value) => value.length, 'Items', 7),
    );

    await Future<dynamic>.delayed(const Duration(seconds: 10));

    expect(
      instance.contains('names'),
      isA<bool>().having((value) => value, 'Expect empty list', false),
    );
  });

  test('Add item if not contains in cache', () async {
    final numbersList = await instance.getOrAdd<List<int>>(
      'numbers',
      addValue: () async {
        final random = Random();
        final numbers = <int>[];
        for (var i = 0; i < 1000; i++) {
          numbers.add(random.nextInt(100));
        }
        return numbers;
      },
    );

    expect(
      numbersList,
      isA<List<int>>().having((value) => value.length, 'Total items', 1000),
    );
  });
}
