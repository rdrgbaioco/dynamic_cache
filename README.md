# Dynamic Cache

A complete in-memory cache in Flutter.
Quickly retrieve an object by context and use it in Stream Builder, Value Listenable Builder or by
instance in business logic. All changes will be reflected in both methods.

## Features
* Wrapper `DynamicCacheProvider` is for the injection of the cache on context for use in the three.
* `Dynamic Cache` can be used directly with `ValueListenableBuilder` and `StreamBuilder` widget, 
but preferably in business logic.
* `Automatic` cache cleaning, with the possibility of setting a time expiration for each item.
* Control notify listeners when the cache is updated.

### Usage `DynamicCache`
<hr>

First, you need to import the package:
```dart
import 'package:dynamic_cache/dynamic_cache.dart';
```

#### For complete example, check the example section.
