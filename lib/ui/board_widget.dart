import 'dart:math';
import 'package:flutter/material.dart';
import '../game/models/player.dart';
import '../game/models/snake_config.dart';
import 'boardGridPainter.dart';
import 'snakes_and_ladders_painter.dart';
import 'ludo_token.dart';

class BoardWidget extends StatefulWidget {
  final List<Player> players;
  final List<SnakeConfig> snakes;
  final Player activePlayer;

  const BoardWidget({
    super.key,
    required this.players,
    required this.snakes,
    required this.activePlayer,
  });

  @override
  BoardWidgetState createState() => BoardWidgetState();
}

/// ✅ PUBLIC — required for GlobalKey
class BoardWidgetState extends State<BoardWidget> {
  final Map<Player, Offset> _animated = {};
  Player? _movingPlayer;
  double _cell = 0;

  // ================= CELL CENTER =================
  Offset _center(int pos) {
    final row = (pos - 1) ~/ 10;
    final col = (pos - 1) % 10;
    final evenRow = row.isEven;

    return Offset(
      (evenRow ? col : 9 - col) * _cell + _cell / 2,
      (9 - row) * _cell + _cell / 2,
    );
  }

  // ================= STEP WALK =================
  Future<void> moveSteps(Player player, int target) async {
    _movingPlayer = player;

    while (player.position < target) {
      await Future.delayed(const Duration(milliseconds: 180));
      setState(() => player.position++);
    }

    _movingPlayer = null;
  }

  // ================= LADDER PATH =================
  Path ladderPath(int start, int end) {
    final s = _center(start);
    final e = _center(end);
    return Path()
      ..moveTo(s.dx, s.dy)
      ..lineTo(e.dx, e.dy);
  }

  // ================= SNAKE PATH =================
  Path snakePath(int head, int tail) {
    final s = _center(head);
    final e = _center(tail);

    final dx = e.dx - s.dx;
    final dy = e.dy - s.dy;
    final len = sqrt(dx * dx + dy * dy);

    final nx = -dy / len;
    final ny = dx / len;

    final path = Path()..moveTo(s.dx, s.dy);

    for (int i = 1; i <= 50; i++) {
      final t = i / 50;
      final wave = sin(t * pi * 4) * _cell * 0.25;
      path.lineTo(s.dx + dx * t + nx * wave, s.dy + dy * t + ny * wave);
    }
    return path;
  }

  // ================= PATH ANIMATION =================
  Future<void> moveAlongPath(Player player, int target, Path path) async {
    _movingPlayer = player;
    final metric = path.computeMetrics().first;

    for (int i = 0; i <= 45; i++) {
      _animated[player] = metric
          .getTangentForOffset(metric.length * i / 45)!
          .position;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 16));
    }

    _animated.remove(player);
    setState(() {
      player.position = target;
      _movingPlayer = null;
    });
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        _cell = size / 10;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: BoardGridPainter(_cell),
                ),
                CustomPaint(
                  size: Size(size, size),
                  painter: SnakesLaddersPainter(
                    cell: _cell,
                    snakes: widget.snakes,
                  ),
                ),
                ..._buildTokens(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TOKENS =================
  List<Widget> _buildTokens() {
    final Map<int, List<Player>> grouped = {};

    for (final p in widget.players) {
      grouped.putIfAbsent(p.position, () => []).add(p);
    }

    final List<Widget> widgets = [];

    grouped.forEach((pos, playersAtCell) {
      for (int i = 0; i < playersAtCell.length; i++) {
        final player = playersAtCell[i];

        final base = _animated[player] ?? _center(pos);

        final offset = (_movingPlayer == player || playersAtCell.length == 1)
            ? base
            : Offset(
                base.dx + cos(2 * pi * i / playersAtCell.length) * _cell * 0.18,
                base.dy + sin(2 * pi * i / playersAtCell.length) * _cell * 0.18,
              );

        widgets.add(
          Positioned(
            left: offset.dx - _cell * 0.21,
            top: offset.dy - _cell * 0.21,
            child: LudoToken(
              color: player.color,
              size: _cell * 0.42,

              // 🟢 ACTIVE PLAYER TOKEN
              isActive: player == widget.activePlayer && _movingPlayer == null,
            ),
          ),
        );
      }
    });

    return widgets;
  }
}
