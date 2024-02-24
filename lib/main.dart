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
        body: const Center(
          child: Text('Hello World!'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: playIt,
        ),
      ),
    );
  }

  void playIt() async {
    AudioCache.instance.prefix = "assets/audio/";
    AudioCache.instance.loadAll([ "example_web_c-c-1.mp3" ]);
    final player = AudioPlayer();
    player.setSource(AssetSource("example_web_c-c-1.mp3"));
    await player.resume();
  }
}
