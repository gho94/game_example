import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';

class BallBounceGame extends FlameGame {
  late SpriteComponent ball;
  double ballSpeedX = 500; // 공의 수평 속도
  double ballSpeedY = 500; // 공의 수직 속도

  @override
  Future<void> onLoad() async {
    // 공 이미지 로드
    ball = SpriteComponent()
      ..sprite = await loadSprite('ball.png')
      ..size = Vector2(50.0, 50.0)
      ..position = Vector2(100.0, 100.0);

    add(ball);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 공의 위치 업데이트
    ball.x += ballSpeedX * dt;
    ball.y += ballSpeedY * dt;

    // 공이 화면 경계를 넘지 않도록 처리
    if (ball.x <= 0 || ball.x >= size.x - ball.width) {
      ballSpeedX = -ballSpeedX; // 수평 속도 반전
    }

    if (ball.y <= 0 || ball.y >= size.y - ball.height) {
      ballSpeedY = -ballSpeedY; // 수직 속도 반전
    }
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(game: BallBounceGame()),
      ),
    ),
  );
}
