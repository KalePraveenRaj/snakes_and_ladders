import 'dart:math';
import 'package:flutter/material.dart';
import '../game/models/player.dart';
import '../home_screen.dart';

class WinnerPopup extends StatefulWidget {
  final Player winner;
  final VoidCallback onRestart;

  const WinnerPopup({super.key, required this.winner, required this.onRestart});

  @override
  State<WinnerPopup> createState() => _WinnerPopupState();
}

class _WinnerPopupState extends State<WinnerPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // 🎊 CONFETTI LAYER
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _ConfettiPainter(progress: _controller.value, rnd: _rnd),
            ),
          ),
        ),

        // 🏆 WINNER CARD
        FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Center(
              child: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 26,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Colors.amber.shade600,
                        shadows: const [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.black26,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        '${widget.winner.name} Wins!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.winner.color,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Congratulations 🎉',
                        style: TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Restart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.winner.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const HomeScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.home),
                            label: const Text('Home'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎊 CONFETTI PAINTER
class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Random rnd;

  _ConfettiPainter({required this.progress, required this.rnd});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 120; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy =
          (rnd.nextDouble() * size.height + progress * size.height) %
          size.height;

      paint.color = Colors.primaries[rnd.nextInt(Colors.primaries.length)]
          .withOpacity(0.85);

      canvas.drawCircle(Offset(dx, dy), rnd.nextDouble() * 4 + 2, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
