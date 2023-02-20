import 'package:flutter/material.dart';
import 'package:dynamic_cache/dynamic_cache.dart';

void main() {
  runApp(
    /// Wrap your app with DynamicCacheProvider
    /// Note: specifying the cache is optional, as it will
    /// create one if it does not receive the parameter.
    const DynamicCacheProvider(
      cache: DynamicCache.instance,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Get a [DynamicCache] global instance to use the cache.
  final _cache = DynamicCache.instance;

  /// Second possible method will be commented below:
  // bool _initialized = false;
  // @override
  // void didChangeDependencies() {
  //   if (!_initialized) {
  //     context.cache.create('counter', 0, autoRemove: false, listen: false);
  //     _initialized = true;
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    /// If using in a widget , initialize the cache first in
    /// initState if the cache is empty before creating widgets that
    /// explicitly depend on this data.
    /// Note: set listen to false to not call the setState method in the build.
    _cache.create('counter', 0, autoRemove: false, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Cache Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              context.cache.get<int>('counter').toString(),
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          context.cache.update<int>('counter', (value) => value + 1);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
