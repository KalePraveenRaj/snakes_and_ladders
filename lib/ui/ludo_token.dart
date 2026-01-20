import 'package:flutter/material.dart';

class LudoToken extends StatelessWidget {
  final Color color;
  final double size;
  final bool isActive;

  const LudoToken({
    super.key,
    required this.color,
    required this.size,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🟢 ACTIVE PLAYER HIGHLIGHT
          if (isActive)
            Container(
              width: size * 1.4,
              height: size * 1.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.8),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

          // 📍 LOCATION ICON TOKEN
          Icon(
            Icons.location_on,
            size: size * 1.2,
            color: color,
            shadows: const [
              Shadow(
                offset: Offset(0, 4),
                blurRadius: 6,
                color: Colors.black38,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
