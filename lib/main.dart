import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MainApp());
}

interface class SequencePlayCompletionListner {
  void sequencePlayCompletion() { }
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

    final chirpPlayer = AudioPlayer(), bogeyPlayer = AudioPlayer(), onePlayer = AudioPlayer(), 
      oclockPlayer = AudioPlayer(), highPlayer = AudioPlayer();
    chirpPlayer.setSource(AssetSource("tr_cl_chirp.mp3"));
    bogeyPlayer.setSource(AssetSource("tr_bogey.mp3"));
    onePlayer.setSource(AssetSource("tr_01.mp3"));
    oclockPlayer.setSource(AssetSource("tr_oclock.mp3"));
    highPlayer.setSource(AssetSource("tr_high.mp3"));

    AudioSequencePlayer([ chirpPlayer, bogeyPlayer, onePlayer, oclockPlayer, highPlayer ], this).playAudioSequence();
  }

  @override
  void sequencePlayCompletion() { 
    print("Done playing sequence");
  }
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