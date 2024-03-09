import 'dart:async';

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

  AudioPlayer _chirpPlayer = new AudioPlayer();
  AudioPlayer _bogeyPlayer = new AudioPlayer();
  int i = 0;

  @override
  void initState() {
    super.initState();
  
    AudioCache cache = AudioCache(prefix:  "assets/audio/");
    cache.loadAll([ "tr_cl_chirp.mp3", "tr_bogey.mp3" ]).then((value) {
      _log("CACHE LOADED");
      _chirpPlayer.audioCache = cache;
      _bogeyPlayer.audioCache = cache;
      _chirpPlayer.setSourceAsset("tr_cl_chirp.mp3").then((value) {
        _log("chirp source set");
        _chirpPlayer.setPlaybackRate(_kPlayRate).then((value) {
          _log("chirp set rate");
        });
      });
      _bogeyPlayer.setSourceAsset("tr_bogey.mp3").then((value) {
        _log("bogey source set");
        _chirpPlayer.setPlaybackRate(_kPlayRate).then((value) {
          _log("bogey set rate");
        });        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const Center(
          child: Text("Play audio by pushing button below")
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
    late StreamSubscription sub;
    sub =_chirpPlayer.onPlayerComplete.listen((event) async {
      _log("chrip done ${i++}");
      sub.cancel();
      _bogeyPlayer.resume();
    });
    _chirpPlayer.resume();
  }
}