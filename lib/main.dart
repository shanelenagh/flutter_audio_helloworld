import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MainApp());
}

interface class SequencePlayCompletionListner {
  void sequencePlayCompletion() { }
}

class AudioSequencePlayer {
  final List<AudioPlayer> _audioPlayers;

  AudioSequencePlayer(List<AudioPlayer> audioPlayers, [SequencePlayCompletionListner? sequenceCompletionListener ]) 
    : _audioPlayers = audioPlayers, assert(audioPlayers.isNotEmpty)
  {
    for (int i = 0; i < _audioPlayers.length; i++) {
      if (i < _audioPlayers.length-1) {
        _audioPlayers.elementAt(i).onPlayerComplete.listen((event) {
          _audioPlayers.elementAt(i+1).resume();
        });
      } else if (sequenceCompletionListener != null) {
        _audioPlayers.elementAt(i).onPlayerComplete.listen((event) {
          sequenceCompletionListener.sequencePlayCompletion();
        });
      }
    }
  }

  void playAudioSequence() {
    _audioPlayers.elementAt(0).resume();
  }
}

class MainApp extends StatelessWidget implements SequencePlayCompletionListner {
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
    await AudioCache.instance.loadAll([ "tr_cl_chirp.mp3", "tr_bogey.mp3", "tr_01.mp3", "tr_oclock.mp3", "tr_high.mp3" ]);
    final chirpPlayer = await _buildLLAudio("tr_cl_chirp.mp3"), bogeyPlayer = await _buildLLAudio("tr_bogey.mp3"), onePlayer = await _buildLLAudio("tr_01.mp3"), 
      oclockPlayer = await _buildLLAudio("tr_oclock.mp3"), highPlayer = await _buildLLAudio("tr_high.mp3");

    AudioSequencePlayer([ chirpPlayer, bogeyPlayer, onePlayer, oclockPlayer, highPlayer ], this).playAudioSequence();
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