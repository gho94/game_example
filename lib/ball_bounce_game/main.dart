import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GameWidget(game: BallBounceGame()),
      ),
    );
  }
}

class BallBounceGame extends FlameGame with KeyboardEvents {
  late SpriteComponent ball;
  late SpriteComponent player;
  late TextComponent scoreText;
  late TextComponent gameOverText;
  double ballSpeedX = 200;
  double ballSpeedY = 200;
  double playerSpeed = 5;
  int score = 0; // 점수
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    ball = SpriteComponent()
      ..sprite = await loadSprite('ball.png')
      ..size = Vector2(50.0, 50.0)
      ..position = Vector2(100.0, 100.0);

    player = SpriteComponent()
      ..sprite = await loadSprite('player.png')
      ..size = Vector2(100.0, 100.0)
      ..position = Vector2(size.x / 2 - 50, size.y - 100);

    // 점수 텍스트
    scoreText = TextComponent(text: 'Score: $score')
      ..position = Vector2(10, 50)
      ..anchor = Anchor.topLeft;

    // 게임 오버 텍스트 (숨기기)
    gameOverText = TextComponent(text: 'Game Over!')
      ..position = Vector2(size.x / 2, size.y / 2)
      ..anchor = Anchor.center
      ..textRenderer = TextPaint(style: const TextStyle(fontSize: 40, color: Colors.red));

    add(ball);
    add(player);
    add(scoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    ball.x += ballSpeedX * dt;
    ball.y += ballSpeedY * dt;

    if (ball.x <= 0 || ball.x >= size.x - ball.width) {
      ballSpeedX = -ballSpeedX;
    }

    if (ball.y <= 0) {
      ballSpeedY = -ballSpeedY;
    }

    if (ball.toRect().overlaps(player.toRect())) {
      ballSpeedY = -ballSpeedY;
      score += 10;
      scoreText.text = 'Score: $score';
    }

    if (ball.y >= size.y) {
      isGameOver = true;
      add(gameOverText);
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (isGameOver) return KeyEventResult.handled;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      player.x -= playerSpeed * event.timeStamp.inMilliseconds / 2000;
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      player.x += playerSpeed * event.timeStamp.inMilliseconds / 2000;
    }

    if (player.x < 0) player.x = 0;
    if (player.x > size.x - player.width) player.x = size.x - player.width;

    return KeyEventResult.handled;
  }
}
