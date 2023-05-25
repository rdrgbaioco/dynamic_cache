import 'package:dynamic_cache/sources/dynamic_cache.dart';
import 'package:flutter/widgets.dart';

/// Extension for ease access to the cache.
extension DynamicCacheCacheExtension on BuildContext {
  DynamicCache get cache => DynamicCacheProvider.of(this);
}

extension AsyncSnapshotCacheExtension on AsyncSnapshot<Map<String, dynamic>> {
  T fromCache<T>(String key) {
    return requireData[key] as T;
  }
}

/// Wrap your app with DynamicCacheProvider
/// for access to the cache instance by context.cache...
class DynamicCacheProvider extends InheritedNotifier<DynamicCache> {
  const DynamicCacheProvider({
    required this.cache,
    required super.child,
    super.key,
  }) : super(notifier: cache);

  final DynamicCache cache;

  static DynamicCache of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<DynamicCacheProvider>()!;
    return inherited.notifier!;
  }
}
