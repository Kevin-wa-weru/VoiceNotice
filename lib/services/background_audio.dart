import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:voicenotice/services/alarm_helper.dart';

class BackgroundAudio {
  // static AudioPlayer player = AudioPlayer();
  // var playerState = PlayerState.stopped;
  AudioPlayer? _player = AudioPlayer();

  // Future init() async {
  //   _player = AudioPlayer();
  // }

  Future dispose() async {
    _player!.dispose();
    _player = null;
  }

  Future playBackgroundAudio(minute, audioPath) async {
    AlarmHelper _alarmHelper = AlarmHelper();

    await _player!
        .play(DeviceFileSource(audioPath))
        .then((value) => _player!.onPlayerComplete.listen((event) async {
              List<PlayerStating> audioState =
                  await _alarmHelper.getAudioState();

              if (audioState.isEmpty) {
              } else {
                print(
                    'BACKGROUND AUDIO CHANGE NOTIFIERRR:::${audioState.first.state}');
                if (DateTime.now().minute > (minute.toInt() + 2) ||
                    audioState.first.state == 'NO') {
                  _player!.stop();
                } else {
                  Timer(const Duration(seconds: 2), () async {
                    await _player!.play(DeviceFileSource(audioPath));
                  });
                }
              }
            }));
  }

  Future stopBackgroundAudio() async {
    _player!.stop();
  }
}









// import 'dart:async';

// import 'package:audioplayers/audioplayers.dart';

// class BackgroundAudio {
//   static AudioPlayer player = AudioPlayer();

//   static playBackgroundAudio(minute, audioPath) async {
//     await player
//         .play(DeviceFileSource(audioPath))
//         .then((value) => player.onPlayerComplete.listen((event) async {
//               // print('HUUUUUUU:::::::::::::$playAudio ');
//               //Play for two minutes max
//               if (DateTime.now().minute > (minute.toInt() + 2)) {
//                 player.stop();
//               } else {
//                 //play at 2 seconds interval
//                 Timer(const Duration(seconds: 2), () async {
//                   await player.play(DeviceFileSource(audioPath));
//                 });
//               }
//             }));
//   }

//   static stopBackgroundAudio() {
//     player.stop();
//   }
// }
