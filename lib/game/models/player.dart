import 'package:flutter/material.dart';

class Player {
  final String name;
  final Color color;
  int position;

  Player({required this.name, required this.color, this.position = 1});
}
