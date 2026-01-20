import 'package:flutter/material.dart';
import '../../game/models/player.dart';
import '../../game_screen.dart';
import '../../game/app_snakes.dart';

class PlayerSetupScreen extends StatefulWidget {
  final int playerCount;

  const PlayerSetupScreen({super.key, required this.playerCount});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  late List<TextEditingController> controllers;
  late List<bool> hasError;

  bool isCardHovered = false;
  bool isButtonHovered = false;

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.playerCount,
      (_) => TextEditingController(),
    );
    hasError = List.generate(widget.playerCount, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Player Names'),
        centerTitle: true,
      ),
      body: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => isCardHovered = true),
          onExit: (_) => setState(() => isCardHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 400,
            padding: const EdgeInsets.all(26),
            transform: isCardHovered
                ? (Matrix4.identity()..translate(0.0, -6.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isCardHovered
                  ? [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Players',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                // 🐍 STYLED INPUT FIELDS
                ...List.generate(widget.playerCount, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextField(
                      controller: controllers[i],
                      onChanged: (_) {
                        if (hasError[i]) {
                          setState(() => hasError[i] = false);
                        }
                      },
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Player ${i + 1}',
                        labelStyle: TextStyle(
                          color: hasError[i]
                              ? Colors.redAccent
                              : Colors.grey.shade700,
                        ),

                        // 🎨 FILLED BACKGROUND
                        filled: true,
                        fillColor: Colors.grey.shade100,

                        // 🎮 PLAYER COLOR ICON
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors[i],
                            shape: BoxShape.circle,
                          ),
                          width: 12,
                          height: 12,
                        ),

                        // 🟢 NORMAL BORDER
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),

                        // 🟢 FOCUSED (SNAKE GLOW)
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),

                        // 🔴 ERROR BORDER
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: hasError[i]
                                ? Colors.redAccent
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),

                        errorText: hasError[i] ? 'Required field' : null,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 30),

                // 🐍 START GAME BUTTON
                SizedBox(
                  width: double.infinity,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => isButtonHovered = true),
                    onExit: (_) => setState(() => isButtonHovered = false),
                    child: GestureDetector(
                      onTap: _startGame,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        transform: isButtonHovered
                            ? (Matrix4.identity()..translate(0.0, -4.0))
                            : Matrix4.identity(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: isButtonHovered
                                ? const [Color(0xFF58D68D), Color(0xFF27AE60)]
                                : const [Color(0xFF2ECC71), Color(0xFF1E8449)],
                          ),
                          boxShadow: isButtonHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.75),
                                    blurRadius: 26,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.5),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: const Center(
                          child: Text(
                            'START GAME 🐍',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🚫 VALIDATION + START GAME
  void _startGame() {
    bool hasAnyError = false;

    // Validate only human inputs
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.trim().isEmpty) {
        hasError[i] = true;
        hasAnyError = true;
      }
    }

    if (hasAnyError) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter player name'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final players = <Player>[];

    // 👤 HUMAN PLAYER
    players.add(Player(name: controllers[0].text.trim(), color: colors[0]));

    // 🤖 AI PLAYER (ONLY for 1 player mode)
    if (widget.playerCount == 1) {
      players.add(Player(name: 'AI', color: Colors.grey));
    } else {
      // 👥 MULTIPLAYER
      for (int i = 1; i < widget.playerCount; i++) {
        players.add(Player(name: controllers[i].text.trim(), color: colors[i]));
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(players: players, snakes: AppSnakes.snakes),
      ),
    );
  }
}
