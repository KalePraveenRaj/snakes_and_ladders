import 'package:flutter/material.dart';
import 'game/game_controller.dart';
import 'game/models/player.dart';
import 'game/board.dart';
import 'ui/board_widget.dart';
import 'ui/dice_widget.dart';
import 'ui/winner_popup.dart';
import 'game/models/snake_config.dart';

final GlobalKey<BoardWidgetState> boardKey = GlobalKey<BoardWidgetState>();

final Map<Player, GlobalKey<DiceWidgetState>> diceKeys = {};

class GameScreen extends StatefulWidget {
  final List<SnakeConfig> snakes;
  final List<Player> players;

  const GameScreen({super.key, required this.snakes, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;

  final ValueNotifier<int> diceValue = ValueNotifier(1);
  bool isRolling = false;
  Player? winner;

  @override
  void initState() {
    super.initState();
    controller = GameController(widget.players);

    for (final p in widget.players) {
      diceKeys[p] = GlobalKey<DiceWidgetState>();
    }
  }

  // ================= GAME LOGIC =================
  Future<void> _rollDice() async {
    if (winner != null || isRolling) return;

    setState(() => isRolling = true);

    final player = controller.currentPlayer;
    final roll = controller.rollDice();
    diceValue.value = roll;

    final board = boardKey.currentState!;
    final start = player.position;

    // 🚫 EXACT DICE RULE (DO NOT MOVE)
    if (start + roll > 100) {
      controller.nextTurn();
      setState(() => isRolling = false);

      // 🤖 AI TURN
      final next = controller.currentPlayer;
      if (next.name == 'AI') {
        Future.delayed(const Duration(milliseconds: 700), () async {
          if (!mounted) return;
          await diceKeys[next]?.currentState?.rollAnimation();
          _rollDice();
        });
      }
      return;
    }

    // ✅ STEP WALK
    final walkTarget = start + roll;
    await board.moveSteps(player, walkTarget);

    int current = walkTarget;

    // 🪜 LADDER
    if (ladders.containsKey(current)) {
      final to = ladders[current]!;
      await board.moveAlongPath(player, to, board.ladderPath(current, to));
      current = to;
    }

    // 🐍 SNAKE
    final snake = widget.snakes.where((s) => s.head == current).toList();
    if (snake.isNotEmpty) {
      final s = snake.first;
      await board.moveAlongPath(
        player,
        s.tail,
        board.snakePath(s.head, s.tail),
      );
      current = s.tail;
    }

    // 🏆 WIN
    if (current == 100) {
      setState(() {
        winner = player;
        isRolling = false;
      });
      return;
    }

    // 🔁 NEXT TURN
    controller.nextTurn();
    setState(() => isRolling = false);

    // 🤖 AI TURN
    final next = controller.currentPlayer;
    if (next.name == 'AI') {
      Future.delayed(const Duration(milliseconds: 700), () async {
        if (!mounted) return;
        await diceKeys[next]?.currentState?.rollAnimation();
        _rollDice();
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: [
          SafeArea(child: isMobile ? _mobileLayout() : _desktopLayout()),
          if (winner != null)
            Container(
              color: Colors.black54,
              child: WinnerPopup(
                winner: winner!,
                onRestart: () {
                  setState(() {
                    winner = null;
                    controller.reset();
                    diceValue.value = 1;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // ================= LAYOUTS =================
  Widget _desktopLayout() {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPlayerPanels(true),
        ),
        Expanded(child: Center(child: _boardCard())),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPlayerPanels(false),
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _buildPlayerPanels(true)),
        ),
        Expanded(child: Center(child: _boardCard())),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _buildPlayerPanels(false)),
        ),
      ],
    );
  }

  Widget _boardCard() {
    return Card(
      elevation: 16,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: BoardWidget(
            key: boardKey,
            players: controller.players,
            snakes: widget.snakes,
            activePlayer: controller.currentPlayer,
          ),
        ),
      ),
    );
  }

  // ================= PLAYER PANELS =================
  List<Widget> _buildPlayerPanels(bool leftSide) {
    final mid = (controller.players.length / 2).ceil();
    final players = leftSide
        ? controller.players.take(mid)
        : controller.players.skip(mid);

    return players.map((player) {
      final active = controller.currentPlayer == player;

      return Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              player.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? player.color : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            DiceWidget(
              key: diceKeys[player],
              value: diceValue,
              enabled: active && !isRolling && winner == null,
              isActive: active && winner == null,
              onRoll: _rollDice,
            ),
          ],
        ),
      );
    }).toList();
  }
}
