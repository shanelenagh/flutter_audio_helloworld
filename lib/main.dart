import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  runApp(const MainApp());
}

abstract class PlayAudioSequenceCompletionListner {
  void sequencePlayCompletion();
}

class AudioSequencePlayer {
  final List<AudioPlayer?> _audioPlayers;
  final Completer _completer;
  StreamSubscription<void>? _lastAudioPlayerSubscription;
  final PlayAudioSequenceCompletionListner? _sequenceCompletionListener;
  int _seqIndex = 0;

  AudioSequencePlayer(List<AudioPlayer?> audioPlayers, [PlayAudioSequenceCompletionListner? sequenceCompletionListener ]) 
    : _audioPlayers = audioPlayers, _completer = Completer(), _sequenceCompletionListener = sequenceCompletionListener, assert(audioPlayers.isNotEmpty)
  {
    _lastAudioPlayerSubscription = _audioPlayers[0]?.onPlayerComplete.listen(_handleNextSeqAudio);      
  }

  void _handleNextSeqAudio(event) {
    _lastAudioPlayerSubscription?.cancel();
    if (_seqIndex < _audioPlayers.length) {
      _lastAudioPlayerSubscription = _audioPlayers[_seqIndex]?.onPlayerComplete.listen(_handleNextSeqAudio);
      _audioPlayers[_seqIndex++]?.resume();
    } else {        
      if (_sequenceCompletionListener != null) {
        _sequenceCompletionListener.sequencePlayCompletion();
      }
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

class MainAppState extends State<MainApp> implements PlayAudioSequenceCompletionListner {
  
  AudioPlayer? _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer;
  bool _isAudioLoaded = false;
  static const double kPlayRate = 1;

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
    AudioSequencePlayer([ _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer, _onePlayer ], this).playAudioSequence();
  }

  Future<AudioPlayer> _buildLowLatencyAudio(String assetSourceName) async {
    final AudioPlayer ap = AudioPlayer();
    await ap.setSource(AssetSource(assetSourceName));
    await ap.setPlaybackRate(kPlayRate);  // Quirk: web loses this after first run--what else is it losing?
    await ap.setPlayerMode(PlayerMode.lowLatency);
    return ap;
  }

  @override
  void sequencePlayCompletion() { 
    print("Done playing sequence");
  }
}