import 'package:dynamic_cache/dynamic_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> names;
  const instance = DynamicCache.instance;

  test('Test instances of DynamicCache', () {
    final instanceA = DynamicCache();
    final instanceB = DynamicCache();
    expect(
      instanceA == instanceB,
      isA<bool>().having((value) => value, 'Expect false', false),
    );

    const instanceC = DynamicCache.instance;
    const instanceD = DynamicCache.instance;
    expect(
      instanceC == instanceD,
      isA<bool>().having((value) => value, 'Expect true', true),
    );
  });

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
    instance.create(
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
}
