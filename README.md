# Dynamic Cache

A complete in-memory cache in Flutter. 
It works either by retrieving the instance from anywhere in your business logic, 
or by context through a provider and an extension.

## Features
* Wrapper `DynamicCacheProvider` is for the injection of the cache on context for use in the three.
* `Dynamic Cache` can be used both directly with widgets, but preferably in business rule, with a suitable state manager.
* `Automatic` cache cleaning, with the possibility of setting a time expiration for each item.
* `DynamicCache` can be used as a singleton, or as a class instance.
* Control notify listeners when the cache is updated.

### Usage `DynamicCache`
<hr>

First, you need to import the package:
```dart
import 'package:dynamic_cache/dynamic_cache.dart';
```

#### For complete example, check the example section.
