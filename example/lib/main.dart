import 'package:example/app.dart';
import 'package:dynamic_cache/dynamic_cache.dart';

void main() {
  runApp(
    const DynamicCacheProvider(
      /// Retrieve or create the cache instance
      cache: DynamicCache.instance,
      child: DynamicCacheApp(),
    ),
  );
}
