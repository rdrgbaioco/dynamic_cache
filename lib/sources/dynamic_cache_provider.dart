import 'package:dynamic_cache/sources/dynamic_cache.dart';
import 'package:flutter/widgets.dart';

/// Extension for ease access to the cache.
extension DynamicCacheExtension on BuildContext {
  DynamicCache get cache => DynamicCacheProvider.of(this);
}

/// Wrap your app with [DynamicCacheProvider] for
/// access to the cache instance on context.cache .
class DynamicCacheProvider extends InheritedNotifier<DynamicCache> {
  const DynamicCacheProvider({
    required super.child,
    super.key,

    /// Note: specifying the cache is optional, as it will
    /// create one if it does not receive the parameter.
    DynamicCache cache = DynamicCache.instance,
  }) : super(notifier: cache);

  static DynamicCache of(BuildContext context, {bool listen = true}) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<DynamicCacheProvider>()!;
    return inherited.notifier!;
  }
}
