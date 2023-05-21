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

}
