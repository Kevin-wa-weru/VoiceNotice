import 'dart:async';

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voicenotice/services/audio_player.dart';
import 'package:voicenotice/services/audio_recorder.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:voicenotice/services/firebase.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({Key? key, required this.user}) : super(key: key);
  final Map<String, dynamic> user;
  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
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
              height: MediaQuery.of(context).size.height * 0.5,
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
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Container(
                              color: Colors.transparent,
                              height: 60,
                              width: 300,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Row(
                                      children: const [
                                        Text('You are creating a new',
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
                                    padding: const EdgeInsets.only(left: 40.0),
                                    child: Row(
                                      children: const [
                                        Text('voice notice for Peter',
                                            style: TextStyle(
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
                              setState(() {
                                isRecording = !isRecording;
                                if (isRecording) {
                                  startTimer();
                                } else {
                                  stopTimer();
                                }
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
            height: 20,
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width - 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text('Select time and date for alarm',
                      style: TextStyle(
                        color: Color(0xCC385A64),
                        // color: Color(0xCC385A64),
                        fontFamily: 'Skranji',
                        fontSize: 18,
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          var pickedDate =
                              await DatePicker.showSimpleDatePicker(
                            context,
                            initialDate: DateTime(2022),
                            firstDate: DateTime(1960),
                            lastDate: DateTime(2040),
                            dateFormat: "dd-MMMM-yyyy",
                            locale: DateTimePickerLocale.en_us,
                            looping: true,
                            backgroundColor: const Color(0xFFF9F9F9),
                            itemTextStyle: const TextStyle(
                              color: Color(0xCC385A64),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                              // fontWeight: FontWeight.w600,
                            ),
                          );

                          setState(() {
                            datePicked = pickedDate;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF7689D6),
                          ),
                          child: Center(
                            child: Text(
                                datePicked == null
                                    ? 'Date'
                                    : '${datePicked!.day}/${datePicked!.month}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Skranji',
                                  fontSize: 18,
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.of(context).push(
                            showPicker(
                              borderRadius: 15,
                              iosStylePicker: true,
                              unselectedColor: const Color(0xCC385A64),
                              accentColor: const Color(0xFF7689D6),
                              okStyle: const TextStyle(
                                color: Color(0xFF7689D6),
                                fontFamily: 'Skranji',
                                fontSize: 18,
                                // fontWeight: FontWeight.w600,
                              ),
                              okText: 'Okay',
                              cancelStyle: const TextStyle(
                                color: Color(0xFFBC343E),
                                fontFamily: 'Skranji',
                                fontSize: 18,
                                // fontWeight: FontWeight.w600,
                              ),
                              blurredBackground: true,
                              context: context,
                              value: _time,
                              onChange: onTimeChanged,
                              minuteInterval: MinuteInterval.ONE,
                              // Optional onChange to receive value as DateTime
                              onChangeDateTime: (DateTime dateTime) {
                                // print(dateTime);
                                debugPrint("[debug datetime]:  $dateTime");
                              },
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF7689D6),
                          ),
                          child: Center(
                            child: Text(
                                _time ==
                                        TimeOfDay.now()
                                            .replacing(hour: 11, minute: 30)
                                    ? 'Time'
                                    : '${_time.hour}:${_time.minute}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Skranji',
                                  fontSize: 18,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        // textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'Skranji', fontWeight: FontWeight.w600),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0.2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0,
                                bottom: 13.0,
                                top: 13.0,
                                right: 20.0),
                            child: SvgPicture.asset('assets/icons/alarm.svg',
                                color: Colors.black, fit: BoxFit.fitHeight),
                          ),
                          filled: true,
                          hintText: 'Alarm title',
                          hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Skranji',
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                        controller: alarmTitleController,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () async {
                      // if (recorder.checkIfRecordingExists() == false) {
                      //   var snackBar =
                      //       const SnackBar(content: Text('Record an audio'));
                      //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      // }

                      if (alarmTitleController.text.isEmpty ||
                          _time ==
                              TimeOfDay.now().replacing(hour: 11, minute: 30) ||
                          datePicked == null) {
                        var snackBar = const SnackBar(
                            content: Text(
                          'Make sure you have selected everything',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Skranji',
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ));
                      } else {
                        setState(() {
                          appisLoading = true;
                        });
                        FirebaseStorage firebaseStorage =
                            FirebaseStorage.instance;

                        var response = await firebaseStorage
                            .ref('Audios')
                            .child(DateTime.now().microsecond.toString())
                            .putFile(File(await player.getFile()));

                        // String audioUrl = await response.ref.getDownloadURL();
                        String audioUrl = response.ref.name;

                        print(audioUrl);

                        var day = datePicked!.day.toString().length == 1
                            ? '0${datePicked!.day.toString()}'
                            : datePicked!.day.toString();

                        var month = datePicked!.month.toString().length == 1
                            ? '0${datePicked!.month.toString()}'
                            : datePicked!.month.toString();

                        var minute = _time.minute.toString().length == 1
                            ? '0${_time.minute.toString()}'
                            : _time.minute.toString();

                        var hour = _time.hour.toString().length == 1
                            ? '0${_time.hour.toString()}'
                            : _time.hour.toString();

                        int year = datePicked!.year;

                        final CollectionReference alarmRef =
                            FirebaseFirestore.instance.collection("alarms");
                        final CollectionReference usersRef =
                            FirebaseFirestore.instance.collection("users");

                        //get userid of the phone to pass as targetUser id

                        var snapshot = await usersRef
                            .where('phone', isEqualTo: widget.user['phone'])
                            .get();

                        var userID = await snapshot.docs.first.id;

                        //  final FirebaseAuth auth = FirebaseAuth.instance;
                        // final User? user = auth.currentUser;
                        // final uid = user!.uid;

                        await alarmRef.add({
                          'AlarmTitle': alarmTitleController.text,
                          'DateTime': DateTime.parse(
                              '$year-$month-${day}T$hour:$minute'),
                          'RecordUrl': 'karate.mp3',
                          'TargetUserid': userID,
                          'CreateByUserID': 'RBlD6eB8zVPhPvxz1czJkxi44Es1',
                          'createdByUserName': widget.user['userName'],
                          //   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
                          // firebaseAuth.currentUser!.displayName!;
                          'createdByPhoneNUmber': widget.user['phone'],
                          // firebaseAuth.currentUser!.phoneNumber!;
                        });

                        var snackBar = const SnackBar(
                            content: Text(
                          'Alarm has been set',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Skranji',
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        setState(() {
                          appisLoading = false;
                        });

                        Timer(const Duration(seconds: 2), () {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        });
                      }
                    },
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
                          : const Center(
                              child: Text('Create Alarm',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Skranji',
                                    fontSize: 18,
                                  )),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
