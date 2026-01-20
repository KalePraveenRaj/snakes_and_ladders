import 'package:flutter/material.dart';
import '../game/models/player.dart';

class PlayerInfo extends StatelessWidget {
  final Player player;

  const PlayerInfo({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          player.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Position: ${player.position}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
