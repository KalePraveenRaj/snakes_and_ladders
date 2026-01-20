import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/models/snake_config.dart';
import 'game/app_snakes.dart';
import 'home_screen.dart';

Future<ui.Image> loadImage(String path) async {
  final data = await rootBundle.load(path);
  return decodeImageFromList(data.buffer.asUint8List());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load snakes ONCE
  AppSnakes.snakes = [
    SnakeConfig(99, 10, await loadImage('assets/snakes/snake_99_10.png')),
    SnakeConfig(70, 55, await loadImage('assets/snakes/snake_70_55.png')),
    SnakeConfig(49, 34, await loadImage('assets/snakes/snake_52_27.png')),
    SnakeConfig(25, 2, await loadImage('assets/snakes/snake_25_2.png')),
    SnakeConfig(95, 72, await loadImage('assets/snakes/snake_95_72.png')),
  ];

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(), // ✅ THIS FIXES HOME SCREEN
    );
  }
}
