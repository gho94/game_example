import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class GameState {
  final double ballX;
  final double ballY;
  final double ballSpeedX;
  final double ballSpeedY;
  final double playerX;
  final int score;
  final bool isGameOver;

  GameState({
    required this.ballX,
    required this.ballY,
    required this.ballSpeedX,
    required this.ballSpeedY,
    required this.playerX,
    required this.score,
    required this.isGameOver,
  });

  GameState copyWith({
    double? ballX,
    double? ballY,
    double? ballSpeedX,
    double? ballSpeedY,
    double? playerX,
    int? score,
    bool? isGameOver,
  }) {
    return GameState(
      ballX: ballX ?? this.ballX,
      ballY: ballY ?? this.ballY,
      ballSpeedX: ballSpeedX ?? this.ballSpeedX,
      ballSpeedY: ballSpeedY ?? this.ballSpeedY,
      playerX: playerX ?? this.playerX,
      score: score ?? this.score,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  GameCubit()
      : super(GameState(
          ballX: 100,
          ballY: 100,
          ballSpeedX: 200,
          ballSpeedY: 200,
          playerX: 100,
          score: 0,
          isGameOver: false,
        ));

  // 게임 업데이트 함수
  void updateGame(double deltaTime, double screenWidth, double screenHeight) {
    if (state.isGameOver) return;

    final newBallX = state.ballX + state.ballSpeedX * deltaTime;
    final newBallY = state.ballY + state.ballSpeedY * deltaTime;

    double newSpeedX = state.ballSpeedX;
    double newSpeedY = state.ballSpeedY;
    int newScore = state.score;

    if (newBallX <= 0 || newBallX >= screenWidth - 50) {
      newSpeedX = -newSpeedX;
      newSpeedY += Random().nextDouble() * 200 - 100;
    }

    if (newBallY <= 0) {
      newSpeedY = -newSpeedY;
      newSpeedX += Random().nextDouble() * 200 - 100;
    }

    if (newBallY >= screenHeight - 150 && newBallY <= screenHeight - 120) {
      if (newBallX >= state.playerX && newBallX <= state.playerX + 100) {
        newSpeedY = -newSpeedY;
        newScore += 10;
        newSpeedX += Random().nextDouble() * 100 - 50;
        newSpeedY += Random().nextDouble() * 50 - 25;
      } else {
        emit(state.copyWith(isGameOver: true));
      }
    }

    emit(state.copyWith(
      ballX: newBallX,
      ballY: newBallY,
      ballSpeedX: newSpeedX,
      ballSpeedY: newSpeedY,
      score: newScore,
    ));
  }

  void movePlayer(double deltaX, double screenWidth) {
    double newPlayerX = state.playerX + deltaX;

    if (newPlayerX < 0) {
      newPlayerX = 0;
    } else if (newPlayerX > screenWidth - 100) {
      newPlayerX = screenWidth - 100;
    }

    emit(state.copyWith(playerX: newPlayerX));
  }

  void resetGame() {
    emit(GameState(
      ballX: 100,
      ballY: 100,
      ballSpeedX: 300,
      ballSpeedY: 300,
      playerX: 100,
      score: 0,
      isGameOver: false,
    ));
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => GameCubit(),
        child: const Scaffold(
          body: BallBounceGame(),
        ),
      ),
    );
  }
}

class BallBounceGame extends StatefulWidget {
  const BallBounceGame({super.key});

  @override
  State<BallBounceGame> createState() => _BallBounceGameState();
}

class _BallBounceGameState extends State<BallBounceGame> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), _updateGame);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateGame(Timer timer) {
    final cubit = BlocProvider.of<GameCubit>(context);
    double deltaTime = 0.016; // 16ms
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    cubit.updateGame(deltaTime, screenWidth, screenHeight);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
                // 왼쪽 화살표 또는 'A'키
                BlocProvider.of<GameCubit>(context).movePlayer(-50, MediaQuery.of(context).size.width);
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
                // 오른쪽 화살표 또는 'D'키
                BlocProvider.of<GameCubit>(context).movePlayer(50, MediaQuery.of(context).size.width);
              }
            }
          },
          child: BlocBuilder<GameCubit, GameState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned(
                    left: state.ballX,
                    top: state.ballY,
                    child: Image.asset(
                      'assets/images/ball.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                  Positioned(
                    left: state.playerX,
                    bottom: 50,
                    child: Image.asset(
                      'assets/images/player.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 50,
                    child: Text(
                      'Score: ${state.score}',
                      style: const TextStyle(fontSize: 30, color: Colors.black),
                    ),
                  ),
                  if (state.isGameOver)
                    const Center(
                      child: Text(
                        'Game Over!',
                        style: TextStyle(fontSize: 40, color: Colors.red),
                      ),
                    ),
                  Positioned(
                    top: 50,
                    right: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<GameCubit>(context).resetGame();
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
