import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const double _kPlayRate = 1.5;

void main() {
  runApp(const MainApp());
}

class AudioSequencePlayer {
  final List<AudioPlayer?> _audioPlayers;
  final Completer _completer = Completer();
  StreamSubscription<void>? _lastAudioPlayerSubscription;
  int _seqIndex = 0;

  AudioSequencePlayer(List<AudioPlayer?> audioPlayers) 
    : _audioPlayers = audioPlayers, assert(audioPlayers.isNotEmpty)
  {
    _lastAudioPlayerSubscription = _audioPlayers[0]?.onPlayerComplete.listen(_handleNextSeqAudio);      
  }

  void _handleNextSeqAudio(event) {
    _lastAudioPlayerSubscription?.cancel();
    if (_seqIndex < _audioPlayers.length) {
      _lastAudioPlayerSubscription = _audioPlayers[_seqIndex]?.onPlayerComplete.listen(_handleNextSeqAudio);
      _audioPlayers[_seqIndex++]?.resume();
    } else {        
      _completer.complete();
    }
  }

  Future<void> playAudioSequence() {
    _audioPlayers[_seqIndex++]?.resume();
    return _completer.future;
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  
  AudioPlayer? _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer;
  bool _isAudioLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _lazyLoadAudio();
    }
  }

  Future<void> _lazyLoadAudio() async {
    if (!_isAudioLoaded) {
      AudioCache.instance.prefix = "assets/audio/";
      await AudioCache.instance.loadAll([ "tr_cl_chirp.mp3", "tr_bogey.mp3", "tr_01.mp3", "tr_oclock.mp3", "tr_high.mp3" ]);
      _chirpPlayer = await _buildLowLatencyAudio("tr_cl_chirp.mp3");
      _bogeyPlayer = await _buildLowLatencyAudio("tr_bogey.mp3");
      _onePlayer = await _buildLowLatencyAudio("tr_01.mp3");
      _oclockPlayer = await _buildLowLatencyAudio("tr_oclock.mp3");
      _highPlayer = await _buildLowLatencyAudio("tr_high.mp3");
      _isAudioLoaded = true;
      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(_isAudioLoaded ? "Play audio by pushing button below" : (kIsWeb ? "Audio load pending user interaction (e.g., push button)..." : "Audio loading..."))
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
      await _lazyLoadAudio();
    }
    AudioSequencePlayer([ _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer, _onePlayer ]).playAudioSequence().then((nothing) {
      print("Done playing sequence");
    });
  }

  Future<AudioPlayer> _buildLowLatencyAudio(String assetSourceName) async {
    final AudioPlayer ap = AudioPlayer();
    await ap.setSource(AssetSource(assetSourceName));
    await ap.setPlaybackRate(_kPlayRate);  // Quirk: web loses this after first run--what else is it losing?
    await ap.setPlayerMode(PlayerMode.lowLatency);
    await ap.setReleaseMode(ReleaseMode.stop);
    return ap;
  }

}