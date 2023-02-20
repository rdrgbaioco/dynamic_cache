import 'dart:async';
import 'package:flutter/foundation.dart';

abstract class DynamicCacheInterface
    extends ValueListenable<Map<String, dynamic>> {
  const DynamicCacheInterface();

  /// Add a key/value pair to the cache, if the key is not already in the cache.
  /// Specify the duration of the cache entry (default 30 seconds).
  void create(
    String key,
    dynamic value, {
    Duration expiration = const Duration(seconds: 30),
  });

  /// Verify if a key exists in the cache.
  bool contains(String key);

  /// Get a value from the cache by key.
  T? get<T>(String key);

  /// Try to get a value from the cache by key.
  /// if the key is not in the cache, will be created.
  T getOrCreate<T>(
    String key, {
    required T Function() tryFunc,
    Duration expiration = const Duration(seconds: 60),
  });

  /// Get a first (if there is more than one) value from the cache by type.
  T? getByType<T>();

  /// Get a first (if there is more than one) value from the cache by type.
  /// if is not in the cache, will be created.
  T getByTypeOrCreate<T>(
    String key, {
    required T Function() tryFunc,
    Duration expiration = const Duration(seconds: 60),
  });

  /// Remove a key from the cache.
  void remove(String key);

  /// Remove all keys from the cache and notify listeners.
  void clear();
}

class DynamicCache extends DynamicCacheInterface {
  const DynamicCache();
  const DynamicCache._() : super();

  /// Get a [DynamicCache] instance.
  static const instance = DynamicCache._();

  static final _cache = <String, dynamic>{};
  static final _listeners = <void Function()>[];
  static final _timers = <String, Timer>{};

  @override
  void create(
    String key,
    dynamic value, {
    bool autoRemove = true,
    Duration expiration = const Duration(seconds: 60),
    bool listen = true,
  }) {
    if (_cache.containsKey(key)) {
      return;
    }
    _cache[key] = value;
    if (autoRemove) {
      _autoRemove(key, expiration);
    }
    if (listen) {
      _notifyListeners();
    }
  }

  void update<T>(
    String key,
    T Function(T oldValue)? update, {
    bool listen = true,
  }) {
    if (!_cache.containsKey(key)) {
      return;
    }
    _cache.update(key, (oldValue) => update?.call(oldValue as T));
    if (listen) {
      _notifyListeners();
    }
  }

  @override
  bool contains(String key) => _cache.containsKey(key);

  @override
  T? get<T>(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  @override
  T getOrCreate<T>(
    String key, {
    required T Function() tryFunc,
    Duration expiration = const Duration(seconds: 60),
  }) {
    if (contains(key)) {
      return _cache[key] as T;
    } else {
      final result = tryFunc();
      create(key, result, expiration: expiration);
      _notifyListeners();
      return result;
    }
  }

  @override
  T? getByType<T>() {
    if (_cache.values.whereType<T>().isNotEmpty) {
      return _cache.values.whereType<T>().first;
    }
    return null;
  }

  @override
  T getByTypeOrCreate<T>(
    String key, {
    required T Function() tryFunc,
    Duration expiration = const Duration(seconds: 60),
  }) {
    if (contains(key)) {
      return _cache[key] as T;
    } else {
      final result = tryFunc();
      create(key, result, expiration: expiration);
      _notifyListeners();
      return result;
    }
  }

  @override
  void remove(String key) {
    _cache.remove(key);
    _notifyListeners();
  }

  void _autoRemove(String key, Duration expiration) {
    _timers[key] = Timer(expiration, () {
      if (!contains(key)) {
        return;
      }
      _cache.remove(key);
      _notifyListeners();
      debugPrint('Removed from cache: $key...');
    });
  }

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  Map<String, dynamic> get value => _cache;

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void clear() {
    _cache.clear();
    for (final timer in _timers.keys) {
      _timers[timer]?.cancel();
      _timers.remove(timer);
    }
    _notifyListeners();
  }
}
