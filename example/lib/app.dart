import 'package:example/src/homepage.dart';
import 'package:flutter/material.dart';

class DynamicCacheApp extends StatelessWidget {
  const DynamicCacheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
