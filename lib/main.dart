import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: playIt,
        ),
      ),
    );
  }

  void playIt() async {
    final player = AudioPlayer();
    await player.play(AssetSource("audio/example_web_c-c-1.mp3"));
  }
}
