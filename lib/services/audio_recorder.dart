import 'dart:io';

import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialised = false;

  bool get isRecording => _audioRecorder!.isRecording;

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone Permission needed');
    }

    await _audioRecorder!.openAudioSession();
    _isRecorderInitialised = true;
  }

  void dispose() {
    if (!_isRecorderInitialised) return;

    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  // final pathToSaveRecorder = 'audio_path.aac';

  getFile() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fullPath = '$tempPath/audio_path.aac';
    File tempFile = File('$tempPath/audio_path.aac');

    return fullPath;
  }

  Future _record() async {
    if (!_isRecorderInitialised) return;

    await _audioRecorder!.startRecorder(toFile: await getFile());
  }

  Future _stoprecord() async {
    if (!_isRecorderInitialised) return;

    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecorder() async {
    if (_audioRecorder!.isStopped) {
      await _record();
      return false;
    } else {
      await _stoprecord();
      return true;
    }
  }

  checkIfRecordingExists() async {
    if (_audioRecorder!.isStopped || _audioRecorder!.isPaused) {
      return true;
    } else {
      return false;
    }
  }

  Future getPath() async {
    var directory = await getApplicationDocumentsDirectory();
    var directoryPath = directory.path;

    return directoryPath;
  }
}
