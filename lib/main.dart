import 'package:flutter/gestures.dart';
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
    AudioCache.instance.loadAll([ /*"example_web_c-c-1.mp3",*/ "tr_cl_chirp.mp3", "tr_bogey.mp3" ]);
    //final playerApplause = AudioPlayer();
    //playerApplause.setSource(AssetSource("example_web_c-c-1.mp3"));
    //await playerApplause.resume();
    final chirpPlayer = AudioPlayer(), bogeyPlayer = AudioPlayer();
    chirpPlayer.setSource(AssetSource("tr_cl_chirp.mp3"));
    bogeyPlayer.setSource(AssetSource("tr_bogey.mp3"));
    //await chirpPlayer.resume();
    bogeyPlayer.onPlayerComplete.listen((event) {
      chirpPlayer.resume();  
    });
    bogeyPlayer.resume(); 
  }
}
