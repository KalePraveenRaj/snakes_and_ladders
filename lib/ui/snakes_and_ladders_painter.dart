import 'dart:math';
import 'package:flutter/material.dart';
import '../game/board.dart'; // contains ladders map
import '../game/models/snake_config.dart';

// ==================== PAINTER ====================
Path buildSnakePath(int head, int tail, double cell) {
  Offset center(int pos) {
    final r = (pos - 1) ~/ 10;
    final c = (pos - 1) % 10;
    final even = r % 2 == 0;
    return Offset(
      (even ? c : 9 - c) * cell + cell / 2,
      (9 - r) * cell + cell / 2,
    );
  }

  final s = center(head);
  final e = center(tail);

  final dx = e.dx - s.dx;
  final dy = e.dy - s.dy;
  final len = sqrt(dx * dx + dy * dy);

  final nx = -dy / len;
  final ny = dx / len;

  final path = Path()..moveTo(s.dx, s.dy);

  for (int i = 1; i <= 50; i++) {
    final t = i / 50;
    final wave = sin(t * pi * 3) * cell * 0.25;
    path.lineTo(s.dx + dx * t + nx * wave, s.dy + dy * t + ny * wave);
  }
  return path;
}

class SnakesLaddersPainter extends CustomPainter {
  final double cell;
  final List<SnakeConfig> snakes;

  SnakesLaddersPainter({required this.cell, required this.snakes});

  // ==================== CELL CENTER ====================

  Offset _center(int pos) {
    final r = (pos - 1) ~/ 10;
    final c = (pos - 1) % 10;
    final even = r % 2 == 0;

    return Offset(
      (even ? c : 9 - c) * cell + cell / 2,
      (9 - r) * cell + cell / 2,
    );
  }

  // ==================== DRAW LADDER ====================

  void _drawLadder(Canvas canvas, Offset start, Offset end) {
    final railPaint = Paint()
      ..color = Colors.brown.shade700
      ..strokeWidth = cell * 0.12
      ..strokeCap = StrokeCap.round;

    final rungPaint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = cell * 0.1
      ..strokeCap = StrokeCap.round;

    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = sqrt(dx * dx + dy * dy);

    final ux = dx / length;
    final uy = dy / length;

    // perpendicular vector
    final px = -uy;
    final py = ux;

    final railGap = cell * 0.25;

    // rails
    final r1s = Offset(start.dx + px * railGap, start.dy + py * railGap);
    final r1e = Offset(end.dx + px * railGap, end.dy + py * railGap);

    final r2s = Offset(start.dx - px * railGap, start.dy - py * railGap);
    final r2e = Offset(end.dx - px * railGap, end.dy - py * railGap);

    canvas.drawLine(r1s, r1e, railPaint);
    canvas.drawLine(r2s, r2e, railPaint);

    // rungs
    final rungCount = (length / (cell * 0.6)).floor();

    for (int i = 1; i <= rungCount; i++) {
      final t = i / (rungCount + 1);
      final cx = start.dx + dx * t;
      final cy = start.dy + dy * t;

      final rs = Offset(cx + px * railGap, cy + py * railGap);
      final re = Offset(cx - px * railGap, cy - py * railGap);

      canvas.drawLine(rs, re, rungPaint);
    }
  }

  // ==================== DRAW SNAKE IMAGE ====================

  void _drawSnake(Canvas canvas, SnakeConfig s) {
    final head = _center(s.head);
    final tail = _center(s.tail);

    final rect = Rect.fromPoints(head, tail).inflate(cell * 0.6);

    canvas.drawImageRect(
      s.image,
      Rect.fromLTWH(0, 0, s.image.width.toDouble(), s.image.height.toDouble()),
      rect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  // ==================== PAINT ====================

  @override
  void paint(Canvas canvas, Size size) {
    // 🪜 DRAW LADDERS
    ladders.forEach((start, end) {
      _drawLadder(canvas, _center(start), _center(end));
    });

    // 🐍 DRAW SNAKES
    for (final s in snakes) {
      _drawSnake(canvas, s);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
