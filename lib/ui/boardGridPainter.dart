import 'package:flutter/material.dart';

class BoardGridPainter extends CustomPainter {
  final double cell;
  BoardGridPainter(this.cell);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(Offset(0, i * cell), Offset(size.width, i * cell), p);
      canvas.drawLine(Offset(i * cell, 0), Offset(i * cell, size.height), p);
    }

    for (int n = 1; n <= 100; n++) {
      final r = (n - 1) ~/ 10;
      final c = (n - 1) % 10;
      final even = r % 2 == 0;

      final dx = (even ? c : 9 - c) * cell + 4;
      final dy = (9 - r) * cell + 4;

      final tp = TextPainter(
        text: TextSpan(
          text: '$n',
          style: const TextStyle(fontSize: 10, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
