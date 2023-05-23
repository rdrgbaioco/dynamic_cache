import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

abstract final interface class IDynamicCache
    extends ValueListenable<Map<String, dynamic>> {
  const IDynamicCache();

  /// Add a key/value pair to the cache, if the key is not already in the cache.
  /// Specify the duration of the cache entry (default 30 seconds).
  void add(
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
  Future<T> getOrCreate<T>(
    String key, {
    required Future<T> Function() createValue,
    Duration expiration = const Duration(seconds: 60),
  });

  /// Try to get a value from the cache by key.
  /// if the key is not in the cache, will be created sync.
  T getOrCreateSync<T>(
    String key, {
    required T createValue,
    Duration expiration = const Duration(seconds: 60),
  });

  /// Get a first (if there is more than one) value from the cache by type.
  T? getByType<T>();

  /// Remove a key from the cache.
  void remove(String key);

  /// Remove all keys from the cache and notify listeners.
  void clear();
}

final class DynamicCache implements IDynamicCache {
  /// Create a new [DynamicCache] instance.
  const DynamicCache._();

  /// Get a [DynamicCache] instance.
  static const instance = DynamicCache._();

  static final HashMap<String, dynamic> _cache = HashMap<String, dynamic>();
  static final HashMap<String, Timer> _timers = HashMap<String, Timer>();

  static final _controller = StreamController<HashMap<String, dynamic>>.broadcast();
  Stream<HashMap<String, dynamic>> get stream => _controller.stream;

  static final List<void Function()> _listeners = [];

  @override
  void add(
    String key,
    dynamic value, {
    bool autoRemove = true,
    Duration expiration = const Duration(seconds: 60),
    bool listen = true,
  }) {

    if (_cache.containsKey(key)) {
      update(key, (oldValue) => value);
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
    T Function(T current)? update, {
    bool listen = true,
  }) {
    if (!_cache.containsKey(key)) {
      return;
    }
    _cache.update(key, (current) => update?.call(current as T));
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
  Future<T> getOrCreate<T>(
    String key,
      {
        required Future<T> Function() createValue,
        Duration expiration = const Duration(seconds: 60),
        bool listen = true,
      }) async {
    if (contains(key)) {
      return await _cache[key] as T;
    } else {
      final value = await createValue();
      add(key, value, expiration: expiration);

      if (listen) {
        _notifyListeners();
      }

      return value;
    }
  }

  @override
  T getOrCreateSync<T>(
    String key, {
    required T createValue,
    Duration expiration = const Duration(seconds: 60),
  }) {
    if (contains(key)) {
      return _cache[key] as T;
    } else {
      add(key, createValue, expiration: expiration);
      _notifyListeners();
      return createValue;
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
  void remove(String key, {bool listen = true}) {
    _cache.remove(key);
    _timers[key]?.cancel();
    if (listen) {
      _notifyListeners();
    }
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
    _controller.add(_cache);
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

  void dispose() {
    clear();
    _controller.close();
  }
}
