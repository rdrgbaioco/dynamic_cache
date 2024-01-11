import 'package:example/app.dart';
import 'package:dynamic_cache/dynamic_cache.dart';

void main() {

  final cache = DynamicCache.singleton();

  cache.add(key: 'Nomes', value: ['John', 'Jane', 'Jack', 'Jill', 'Jack', 'Annie', 'Bill']);

  print(cache.get('Nomes'));

  runApp(const DynamicCacheApp());
}
