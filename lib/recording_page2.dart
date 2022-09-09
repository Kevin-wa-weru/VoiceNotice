import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voicenotice/Cubits/cubit/sent_voices_cubit.dart';
import 'package:voicenotice/services/audio_player.dart';
import 'package:voicenotice/services/audio_recorder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecordingPage2 extends StatefulWidget {
  const RecordingPage2({Key? key, required this.contact}) : super(key: key);
  final Contact contact;
  @override
  State<RecordingPage2> createState() => _RecordingPage2State();
}

class _RecordingPage2State extends State<RecordingPage2> {
  late List<dynamic>? allSentMessages = [];
  int currentIndex = 0;
  Duration duration = const Duration();
  Timer? timer;
  final alarmTitleController = TextEditingController();
  DateTime? datePicked;

  bool appisLoading = false;

  Widget buidTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Text('$minutes:$seconds',
        style: const TextStyle(
          color: Color(0xFF7689D6),
          fontFamily: 'Skranji',
          fontSize: 28,
        ));
  }

  void resetTime() {
    setState(() {
      duration = const Duration();
    });
  }

  final recorder = SoundRecorder();
  bool isRecording = false;

  final player = SoundPlayer();
  bool isPlaying = false;

  TimeOfDay _time = TimeOfDay.now().replacing(hour: 11, minute: 30);
  bool iosStyle = true;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  void initState() {
    super.initState();

    recorder.init();
    player.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    player.dispose();
    super.dispose();
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer() {
    setState(() {
      timer!.cancel();
    });
  }

  addTime() {
    const addSecond = 1;

    setState(() {
      final seconds = duration.inSeconds + addSecond;

      duration = Duration(seconds: seconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 20.0, bottom: 10.0),
              child: Row(
                children: const [
                  Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                    size: 25,
                  )
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.52,
              width: MediaQuery.of(context).size.width - 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Container(
                              color: Colors.transparent,
                              height: 60,
                              width: 250,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Row(
                                      children: const [
                                        Text('You are creating an instant',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Row(
                                      children: [
                                        Text(
                                            'voice notice for ${widget.contact.displayName}',
                                            style: const TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          color: Colors.white,
                          height: 80,
                          width: 200,
                          child: Image.asset(
                            "assets/images/gif1.gif",
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: Colors.transparent,
                        height: MediaQuery.of(context).size.height * 0.20,
                        child: AvatarGlow(
                          glowColor: const Color(0x1A7689D6),
                          endRadius: 140,
                          animate: isRecording,
                          repeatPauseDuration:
                              const Duration(milliseconds: 100),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(70),
                              ),
                              border: Border.all(
                                color: const Color(0x33000000),
                                width: 1,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: const Color(0x337689D6),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 25.00,
                                      width: 20.00,
                                      child: SvgPicture.asset(
                                          'assets/icons/microphone.svg',
                                          height: 6,
                                          color: const Color(0xFFBC343E),
                                          fit: BoxFit.fitHeight),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buidTime(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text('Press Start',
                                        style: TextStyle(
                                          color: Color(0xCC385A64),
                                          fontFamily: 'Skranji',
                                          fontSize: 15,
                                        )),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              final player = AudioPlayer();

                              await player.play(AssetSource('record.mp3'));

                              Timer(const Duration(seconds: 1), () {
                                setState(() {
                                  isRecording = !isRecording;
                                  if (isRecording) {
                                    startTimer();
                                  } else {
                                    stopTimer();
                                  }
                                });
                              });

                              await recorder.toggleRecorder();
                            },
                            child: Container(
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isRecording
                                    ? const Color(0xFFBC343E)
                                    : const Color(0xFF7689D6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 19.00,
                                    width: 20.5,
                                    child: SvgPicture.asset(
                                        'assets/icons/microphone.svg',
                                        color: Colors.white,
                                        height: 6,
                                        fit: BoxFit.fitHeight),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(isRecording ? 'Stop' : 'Start',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Skranji',
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          InkWell(
                            onTap: () async {
                              setState(() {
                                isPlaying = !isPlaying;
                              });
                              await player.togglePlaying(whenFinished: () {
                                setState(() {
                                  isPlaying = false;
                                });
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isPlaying
                                    ? const Color(0xFFBC343E)
                                    : const Color(0xFF7689D6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 17.00,
                                    width: 20.5,
                                    child: SvgPicture.asset(
                                        'assets/icons/play.svg',
                                        color: Colors.white,
                                        height: 6,
                                        fit: BoxFit.fitHeight),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(isPlaying ? 'Stop' : 'Play',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Skranji',
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () async {
              setState(() {
                appisLoading = true;
              });
              FirebaseStorage firebaseStorage = FirebaseStorage.instance;

              var response = await firebaseStorage
                  .ref('Audios')
                  .child(
                      '${DateTime.now().microsecond.toString()}${DateTime.now().second.toString()}')
                  .putFile(File(await player.getFile()));

              String audioUrl = response.ref.name;
              String audioCompleteUrl = await response.ref.getDownloadURL();

              final CollectionReference alarmRef =
                  FirebaseFirestore.instance.collection("messages");
              final CollectionReference usersRef =
                  FirebaseFirestore.instance.collection("users");

              //get userid of the phone to pass as targetUser id
              var snapshot = await usersRef
                  .where('phone',
                      isEqualTo: widget.contact.phones![0].value!
                          .replaceAll(RegExp(' '), ''))
                  .get();

              var userID = snapshot.docs.first.id;

              late List specificUser = [];

              for (var user in snapshot.docs) {
                specificUser.add(user['userName']);
              }

              final FirebaseAuth auth = FirebaseAuth.instance;
              final User? user = auth.currentUser;

              await alarmRef.add({
                'DateTime': DateTime.now(),
                'RecordUrl': audioUrl,
                'audioCompleteUrl':
                    'https://firebasestorage.googleapis.com/v0/b/voicenote-1784f.appspot.com/o/Audios%2Fkarate.mp3?alt=media&token=35125165-6f99-4459-8539-e10d5b4fc32c',
                'CreateByUserID': user!.uid,
                'createdByUserName': user.displayName,
                'createdByPhoneNUmber': user.phoneNumber,
                'TargetUserid': user.uid,
                "createdForUserName": specificUser[0],
                'createdForPhoneNUmber': widget.contact.phones![0].value!,
              });

              setState(() {
                appisLoading = false;
              });

              var snackBar = const SnackBar(
                  content: Text(
                'Notice has been sent',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Skranji',
                    fontWeight: FontWeight.w500,
                    fontSize: 18),
              ));
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              // ignore: use_build_context_synchronously
              context.read<SentVoicesCubit>().getSentMessages();

              Timer(const Duration(seconds: 2), () {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF7689D6),
                ),
                child: appisLoading == true
                    ? const Center(
                        child: SizedBox(
                          height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3.0,
                          ),
                        ),
                      )
                    : Center(
                        child: Text('Send to ${widget.contact.displayName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
