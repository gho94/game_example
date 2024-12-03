import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => TouchGameCubit(),
        child: const TouchGameScreen(),
      ),
    );
  }
}

class TouchGameCubit extends Cubit<int> {
  TouchGameCubit() : super(0);

  void increment() => emit(state + 1);
}

class TouchGameScreen extends StatelessWidget {
  const TouchGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Touch Game'),
      ),
      body: BlocBuilder<TouchGameCubit, int>(
        builder: (context, score) {
          return GestureDetector(
            onTap: () => context.read<TouchGameCubit>().increment(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '점수: $score',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '화면을 터치하세요!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
