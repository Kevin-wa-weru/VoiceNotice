import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class SoundPlayer {
  // final pathToReadRecorder = 'audio_path.aac';

  getFile() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fullPath = '$tempPath/audio_path.aac';
    File tempFile = File('$tempPath/audio_path.aac');

    return fullPath;
  }

  FlutterSoundPlayer? _audioPlayer;
  bool get isPlaying => _audioPlayer!.isPlaying;
  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    _audioPlayer!.openAudioSession();
  }

  Future dispose() async {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play(VoidCallback whenFinished) async {
    await _audioPlayer!.startPlayer(
      fromURI: await getFile(),
      whenFinished: whenFinished,
    );
  }

  Future _stopPlayer() async {
    await _audioPlayer!.stopPlayer();
  }

  Future togglePlaying({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else {
      await _stopPlayer();
    }
  }
}
