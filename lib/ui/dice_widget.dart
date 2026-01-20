import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final VoidCallback onRoll;
  final ValueNotifier<int> value;
  final bool enabled;
  final bool isActive;

  const DiceWidget({
    super.key,
    required this.onRoll,
    required this.value,
    required this.enabled,
    required this.isActive,
  });

  @override
  DiceWidgetState createState() => DiceWidgetState();
}

/// ✅ PUBLIC — used by GlobalKey
class DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> rollAnimation() async {
    await _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = widget.enabled ? 1.0 : 0.35;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.enabled
            ? () async {
                await rollAnimation();
                widget.onRoll();
              }
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Transform.rotate(
                angle: _controller.value * 2 * 3.1415926,
                child: _face(),
              ),
            ),

            // 🟢 ACTIVE TURN INDICATOR
            if (widget.isActive)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _face() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: ValueListenableBuilder<int>(
          valueListenable: widget.value,
          builder: (_, value, __) => Text(
            '$value',
            style: const TextStyle(
              fontSize: 30,
              height: 1.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
