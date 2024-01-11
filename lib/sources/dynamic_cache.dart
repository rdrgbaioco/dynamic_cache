import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

class CacheValue<T> {
  const CacheValue({
    required this.key,
    required this.value,
  });

  final String key;
  final T value;
}

class CacheTimer {
  const CacheTimer({
    required this.key,
    required this.timer,
  });

  final String key;
  final Timer timer;
}


abstract class IDynamicCache {
  IDynamicCache();

  final HashSet<CacheValue<dynamic>> cache = HashSet<CacheValue<dynamic>>();

  T? get<T>(String key);

  void add<T extends Object>({
    required String key,
    required T value,
    Duration? expiration,
  });

  void remove<T extends Object>(String key);

  void update<T extends Object>(String key, T Function(T) update);

  bool contains(String key);
}

class DynamicCache extends IDynamicCache {
  DynamicCache();

  factory DynamicCache.singleton() {
    return _singleton ??= DynamicCache();
  }

  static DynamicCache? _singleton;

  final HashSet<CacheTimer> _timers = HashSet<CacheTimer>();

  void _removeFromCache(String key, void Function()? onExpire) {
    if (!contains(key)) {
      return;
    }
    cache.remove(cache.firstWhere((e) => e.key == key));
    debugPrint('Removed from cache: $key...');
    onExpire?.call();
  }

  void _expiration(String key, Duration expiration, void Function()? onExpire) {
    final timer = CacheTimer(
      key: key,
      timer: Timer(expiration, () => _removeFromCache(key, onExpire)),
    );
    _timers.add(timer);
  }

  @override
  bool contains(String key) {
    return cache.any((e) => e.key == key);
  }

  @override
  void add<T extends Object>({
    required String key,
    required T value,
    Duration? expiration,
    void Function()? onExpire,
  }) {
    final cacheValue = CacheValue(key: key, value: value);
    cache.add(cacheValue);
    if (expiration != null) {
      _expiration(key, expiration, onExpire);
    }
  }

  @override
  T? get<T>(String key) {
    return cache.firstWhere((e) => e.key == key).value as T;
  }

  T getOr<T extends Object>(String key, {required T Function() orElse}) {
    final values = cache.where((e) => e.key == key);
    if (values.isNotEmpty) {
      return values.first.value as T;
    }
    return orElse();
  }

  @override
  void remove<T extends Object>(String key) {
    cache.remove(cache.firstWhere((e) => e.key == key));
    if (_timers.any((e) => e.key == key)) {
      _timers.removeWhere((e) => e.key == key);
    }
  }

  @override
  void update<T extends Object>(String key, T Function(T current) update) {
    final cacheValue = cache.firstWhere((e) => e.key == key);
    final updatedValue = update(cacheValue.value as T);
    cache..clear()..addAll(cache.map((e) {
      if (e.key == key) {
        return CacheValue(key: key, value: updatedValue);
      }
      return e;
    }),);
  }
}


// abstract interface class IDynamicCache extends ValueListenable<Map<String, dynamic>> {
//   const IDynamicCache();
//
//   /// Add a key/value pair to the cache, if the key is not already in the cache.
//   /// Specify the duration of the cache entry (default 30 seconds).
//   void add(
//     String key,
//     dynamic value, {
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   });
//
//   /// Verify if a key exists in the cache.
//   bool contains(String key);
//
//   /// Get a value from the cache by key.
//   T? get<T>(String key);
//
//   /// Try to get a value from the cache by key.
//   /// if the key is not in the cache, will be created.
//   Future<T> getOrAdd<T>(
//     String key, {
//     required Future<T> Function() addValue,
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   });
//
//   /// Try to get a value from the cache by key.
//   /// if the key is not in the cache, will be created sync.
//   T getOrAddSync<T>(
//     String key, {
//     required T addValue,
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   });
//
//   /// Get a first (if there is more than one) value from the cache by type.
//   T? getByType<T>();
//
//   /// Remove a key from the cache.
//   void remove(String key);
//
//   /// Remove all keys from the cache and notify listeners.
//   void clear();
// }
//
// class DynamicCache implements IDynamicCache {
//   /// Create a new [DynamicCache] instance.
//   const DynamicCache._();
//
//   /// Get a [DynamicCache] instance.
//   static const instance = DynamicCache._();
//
//   static final HashMap<String, dynamic> _cache = HashMap<String, dynamic>();
//   static final HashMap<String, Timer> _timers = HashMap<String, Timer>();
//
//   static final _controller =
//       StreamController<HashMap<String, dynamic>>.broadcast();
//   Stream<HashMap<String, dynamic>> get stream => _controller.stream;
//
//   static final List<void Function()> _listeners = [];
//
//   @override
//   void add(
//     String key,
//     dynamic value, {
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   }) {
//     if (_cache.containsKey(key)) {
//       update(key, (oldValue) => value);
//       return;
//     }
//     _cache[key] = value;
//
//     if (autoRemove) {
//       _autoRemove(key, expiration);
//     }
//
//     if (listen) {
//       _notifyListeners();
//     }
//   }
//
//   void update<T>(
//     String key,
//     T Function(T current)? update, {
//     bool listen = true,
//   }) {
//     if (!_cache.containsKey(key)) {
//       return;
//     }
//     _cache.update(key, (current) => update?.call(current as T));
//     if (listen) {
//       _notifyListeners();
//     }
//   }
//
//   @override
//   bool contains(String key) => _cache.containsKey(key);
//
//   @override
//   T? get<T>(String key) {
//     if (_cache.containsKey(key)) {
//       return _cache[key] as T?;
//     }
//     return null;
//   }
//
//   @override
//   Future<T> getOrAdd<T>(
//     String key, {
//     required Future<T> Function() addValue,
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   }) async {
//     if (contains(key)) {
//       return await _cache[key] as T;
//     } else {
//       final value = await addValue();
//       add(
//         key,
//         value,
//         autoRemove: autoRemove,
//         expiration: expiration,
//         listen: listen,
//       );
//
//       if (listen) {
//         _notifyListeners();
//       }
//
//       return value;
//     }
//   }
//
//   @override
//   T getOrAddSync<T>(
//     String key, {
//     required T addValue,
//     bool autoRemove = true,
//     Duration expiration = const Duration(seconds: 60),
//     bool listen = true,
//   }) {
//     if (contains(key)) {
//       return _cache[key] as T;
//     } else {
//       add(
//         key,
//         addValue,
//         autoRemove: autoRemove,
//         expiration: expiration,
//         listen: listen,
//       );
//       _notifyListeners();
//       return addValue;
//     }
//   }
//
//   @override
//   T? getByType<T>() {
//     if (_cache.values.whereType<T>().isNotEmpty) {
//       return _cache.values.whereType<T>().first;
//     }
//     return null;
//   }
//
//   @override
//   void remove(String key, {bool listen = true}) {
//     _cache.remove(key);
//     _timers[key]?.cancel();
//     if (listen) {
//       _notifyListeners();
//     }
//   }
//
//   void _autoRemove(String key, Duration expiration) {
//     _timers[key] = Timer(expiration, () {
//       if (!contains(key)) {
//         return;
//       }
//       _cache.remove(key);
//       _notifyListeners();
//       debugPrint('Removed from cache: $key...');
//     });
//   }
//
//   @override
//   void addListener(void Function() listener) => _listeners.add(listener);
//
//   @override
//   void removeListener(void Function() listener) => _listeners.remove(listener);
//
//   @override
//   Map<String, dynamic> get value => _cache;
//
//   void _notifyListeners() {
//     _controller.add(_cache);
//     for (final listener in _listeners) {
//       listener();
//     }
//   }
//
//   @override
//   void clear() {
//     _cache.clear();
//     for (final timer in _timers.keys) {
//       _timers[timer]?.cancel();
//       _timers.remove(timer);
//     }
//     _notifyListeners();
//   }
//
//   void dispose() {
//     clear();
//     _controller.close();
//   }
// }
