import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MainApp());
}

interface class SequencePlayCompletionListner {
  void sequencePlayCompletion() { }
}

class AudioSequencePlayer {
  final List<AudioPlayer?> _audioPlayers;

  AudioSequencePlayer(List<AudioPlayer?> audioPlayers, [SequencePlayCompletionListner? sequenceCompletionListener ]) 
    : _audioPlayers = audioPlayers, assert(audioPlayers.isNotEmpty)
  {
    for (int i = 0; i < _audioPlayers.length; i++) {
      if (i < _audioPlayers.length-1) {
        _audioPlayers.elementAt(i)?.onPlayerComplete.listen((event) {
          _audioPlayers.elementAt(i+1)?.resume();
        });
      } else if (sequenceCompletionListener != null) {
        _audioPlayers.elementAt(i)?.onPlayerComplete.listen((event) {
          sequenceCompletionListener.sequencePlayCompletion();
        });
      }
    }
  }

  void playAudioSequence() {
    _audioPlayers.elementAt(0)?.resume();
  }
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> implements SequencePlayCompletionListner {
  
  AudioPlayer? _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer;
  bool _isAudioLoaded = false;

  Future<void> _loadAudio() async {
    if (!_isAudioLoaded) {
      AudioCache.instance.prefix = "assets/audio/";
      await AudioCache.instance.loadAll([ "tr_cl_chirp.mp3", "tr_bogey.mp3", "tr_01.mp3", "tr_oclock.mp3", "tr_high.mp3" ]);
      _chirpPlayer = await _buildLLAudio("tr_cl_chirp.mp3");
      _bogeyPlayer = await _buildLLAudio("tr_bogey.mp3");
      _onePlayer = await _buildLLAudio("tr_01.mp3");
      _oclockPlayer = await _buildLLAudio("tr_oclock.mp3");
      _highPlayer = await _buildLLAudio("tr_high.mp3");
      _isAudioLoaded = true;
      setState(() { });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(_isAudioLoaded ? "Play audio again below" : "Audio load pending user interaction...")
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: playIt,
        ),
      ),
    );
  }

  void playIt() async {
    await _loadAudio();
    AudioSequencePlayer([ _chirpPlayer, _bogeyPlayer, _onePlayer, _oclockPlayer, _highPlayer ], this).playAudioSequence();
  }

  Future<AudioPlayer> _buildLLAudio(String assetSourceName) async {
    final AudioPlayer ap = AudioPlayer();
    await ap.setSource(AssetSource(assetSourceName));
    await ap.setPlayerMode(PlayerMode.lowLatency);
    return ap;
  }

  @override
  void sequencePlayCompletion() { 
    print("Done playing sequence");
  }
}