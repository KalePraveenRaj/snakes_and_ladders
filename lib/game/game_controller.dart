import 'dart:math';
import 'models/player.dart';
import 'board.dart'; // snakes & ladders maps

class GameController {
  final Random _rnd = Random();
  final List<Player> players;

  int currentPlayerIndex = 0;

  GameController(this.players);

  Player get currentPlayer => players[currentPlayerIndex];

  int rollDice() => _rnd.nextInt(6) + 1;

  /// 🔥 RETURNS FULL MOVE PATH
  /// example: [28, 84, 42]
  List<int> resolveMovePath(int start, int roll) {
    final path = <int>[start];

    int pos = start + roll;
    if (pos > 100) return path;

    path.add(pos);

    // ladder
    if (ladders.containsKey(pos)) {
      pos = ladders[pos]!;
      path.add(pos);
    }

    // snake (AFTER ladder)
    if (snakes.containsKey(pos)) {
      pos = snakes[pos]!;
      path.add(pos);
    }

    return path;
  }

  void nextTurn() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void reset() {
    currentPlayerIndex = 0;
    for (final p in players) {
      p.position = 1;
    }
  }
}
