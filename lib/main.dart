import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const double _kPlayRate = 1.2;

void _log(String msg) {
  print("${DateTime.now().millisecondsSinceEpoch}: $msg");
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: const Text("Play audio by pushing button below")
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: playIt,
          child: const Text("Play Audio")
        ),
      ),
    );
  }

  void playIt() async {
    if (kIsWeb) {
      //await _lazyLoadAudio();
    }
    AudioCache cache = AudioCache(prefix:  "assets/audio/");
    await cache.loadAll([ "tr_cl_chirp.mp3", "tr_bogey.mp3" ]);
    AudioPlayer player = AudioPlayer();
    player.audioCache = cache;
    await player.setReleaseMode(ReleaseMode.stop);
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setPlaybackRate(1.5);
    _log("chirp started");
    bool playedBogey = false;
    player.onPlayerComplete.listen((event) async {
      _log("sound done");
      if (!playedBogey) {
        playedBogey = true;
        await player.setSourceAsset("tr_cl_chirp.mp3");
        await player.setPlaybackRate(_kPlayRate);
        player.resume();
      }
    });
    await player.setSourceAsset("tr_bogey.mp3");
    await player.setPlaybackRate(_kPlayRate);
    await player.setPlayerMode(PlayerMode.lowLatency);
    player.resume();
  }
}