import 'dart:async';
import 'dart:io';
import 'dart:ui';
//add
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voicenotice/Cubits/cubit/all_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_permission_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_without_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicenotice/Cubits/cubit/received_message_cubit.dart';
import 'package:voicenotice/Cubits/cubit/sent_voices_cubit.dart';
import 'package:voicenotice/homepage.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/services/alarm_helper.dart';
import 'package:voicenotice/services/background_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:voicenotice/services/notifications.dart';
import 'Cubits/cubit/create_alarms_cubit.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeService();
  MobileAds.instance.initialize();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('mipmap/ic_launcher');
  var initializationSettingsIOS = const IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) async {
    AlarmHelper alarmHelper = AlarmHelper();
    alarmHelper.updateAudioState('NO', 'PANAMA');
    List<PlayerStating> audioState = await alarmHelper.getAudioState();
    Timer(const Duration(seconds: 2), () async {
      alarmHelper.deleteAudioState(audioState.first.constName!);
    });
  });
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  late String userid = '';
  if (user == null) {
    userid = '';
  } else {
    userid = user.uid;
  }

  runApp(MyApp(
    userid: userid,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.userid}) : super(key: key);
  final String? userid;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AllAlarmsCubit(),
        ),
        BlocProvider(
          create: (context) => EditTimeCubit(),
        ),
        BlocProvider(
          create: (contex) => CreateAlarmsCubit(),
        ),
        BlocProvider(
          create: (contex) => ReceivedMessageCubit(),
        ),
        BlocProvider(
          create: (contex) => SentVoicesCubit(),
        ),
        BlocProvider(
          create: (contex) => ContactsWithPermissionCubit(),
        ),
        BlocProvider(
          create: (contex) => ContactsWithAppCubit(),
        ),
        BlocProvider(
          create: (contex) => ContactsWithoutAppCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: userid == '' ? const OnboardingScreen() : const HomePage(),
      ),
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();

  return true;
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  late String userid = '';
  await Firebase.initializeApp();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  if (user == null) {
    userid = '';
  } else {
    userid = user.uid;
  }
  listenToIcomingMessage() async {
    final player = AudioPlayer();

    if (userid == '') {
      debugPrint('BACKGROUNDDDDDDD NAME IN MESSAGING:::::::::IS EMPTY');
    } else {
      debugPrint('BACKGROUNDDDDDDD NAME IN MESSAGING:::::::::$userid');

      final docRef = FirebaseFirestore.instance
          .collection("messages")
          .where('TargetUserid', isEqualTo: userid);
      docRef.snapshots(includeMetadataChanges: true).listen(
        (event) async {
          debugPrint("current data: ${event.docs}");
          for (var message in event.docChanges) {
            AlarmHelper alarmHelper = AlarmHelper();
            bool messageExists = await alarmHelper
                .checkIfMessageExists(message.doc.data()!['RecordUrl']);

            if (messageExists == true) {
              debugPrint('Message Exixts');
            } else {
              await player.play(AssetSource('beyond.mp3'));

              alarmHelper.insertMessage(
                  MessageInfo(recordUrl: message.doc.data()!['RecordUrl']));

              Timer(const Duration(seconds: 4), () async {
                await player
                    .play(UrlSource(message.doc.data()!['audioCompleteUrl']));
              });

              Notificationed.showNotification(
                  title: 'New Voice Notice',
                  body: 'From ${message.doc.data()!['createdByUserName']}');
            }
          }
        },
        onError: (error) => debugPrint("Listen failed: $error"),
      );
    }
  }

  listenToIcomingMessage();

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    // if (service is AndroidServiceInstance) {
    //   service.setForegroundNotificationInfo(
    //     title: "My App Service",
    //     content: "Updated at ${DateTime.now()}",
    //   );
    // }

    if (userid == '') {
      debugPrint('BACKGROUNDDDDDDD NAME IN ALARMS:::::::::IS EMPTY');
    } else {
      debugPrint('BACKGROUNDDDDDDD NAME ALARMS:::::::::$userid');
      var userData = await FirebaseFirestore.instance
          .collection("alarms")
          .where('TargetUserid', isEqualTo: userid)
          .get();

      if (userData.docs.isEmpty) {
        debugPrint('BACKGROUND:::: USER HAS NO ALARMS');
      } else {
        AlarmHelper alarmHelper = AlarmHelper();
        alarmHelper
            .initializeDatabase()
            .then((value) => debugPrint('====DATABASE INITIALISED'));

//SAVE AUDIO TO LOCAL STORAGE
        saveToLocal(audioUrl, date) async {
          Directory appDocDir = await getApplicationDocumentsDirectory();
          File downloadToFile = File('${appDocDir.path}/$date');
          FirebaseStorage firebaseStorage = FirebaseStorage.instance;
          await firebaseStorage
              .ref('Audios/$audioUrl')
              .writeToFile(downloadToFile);

          return '${appDocDir.path}/$date';
        }

        late List alarms = [];

        for (var user in userData.docs) {
          alarms.add(user.data());
        }

        late List filteredAlarms = [];

        for (var alarm in alarms) {
          bool exists =
              await alarmHelper.checkIfAlarmExists(alarm['RecordUrl']);

          if (exists) {
            alarmHelper.updateAlarm(
                DateTime.parse(alarm['DateTime'].toDate().toString()).hour,
                DateTime.parse(alarm['DateTime'].toDate().toString()).minute,
                alarm['RecordUrl']);
          } else {
            filteredAlarms.add(alarm);
          }
        }

        debugPrint('MAINNN FILTERED ALARMS  ===== $filteredAlarms');

        if (filteredAlarms.isEmpty) {
          debugPrint(
              'BACKGROUNDS:::::::   FILTERED THROUGH LOCAL DB AND FOUND SIMILAR ALARAMS');
        } else {
          late List<AlarmInfo> alarmInformation = [];
          for (var alarm in filteredAlarms) {
            var alarmInfo = AlarmInfo(
              title: alarm['AlarmTitle'],
              alarmDateTime:
                  DateTime.parse(alarm['DateTime'].toDate().toString()),
              hour: DateTime.parse(alarm['DateTime'].toDate().toString()).hour,
              minute:
                  DateTime.parse(alarm['DateTime'].toDate().toString()).minute,
              creator: alarm['createdByUserName'],
              audioPath:
                  await saveToLocal(alarm['RecordUrl'], alarm['DateTime']),
              fileRef: alarm['RecordUrl'],
            );
            alarmInformation.add(alarmInfo);
          }

          for (var alarm in alarmInformation) {
            alarmHelper.insertAlarm(alarm);
          }
        }

        List<AlarmInfo> alarmsInLocalDB = await alarmHelper.getAlarms();
        for (var alarm in alarmsInLocalDB) {
          debugPrint(
              'BACKGROUND NOTIFICATION:::::::::::::::::${DateTime.now().hour}');
          debugPrint(
              'BACKGROUND NOTIFICATION:::::::::::::::::${DateTime.now().minute}');
          debugPrint('BACKGROUND NOTIFICATION:::::::::::::::::${alarm.hour}');
          debugPrint('BACKGROUND NOTIFICATION:::::::::::::::::${alarm.minute}');
          debugPrint(
              'BACKGROUND NOTIFICATION:::::::::::::::::${alarm.audioPath!}');
          if (DateTime.now().day == alarm.alarmDateTime!.day &&
              DateTime.now().hour == alarm.hour &&
              DateTime.now().minute == alarm.minute) {
            alarmHelper.insertAudioState(PlayerStating(
              constName: 'PANAMA',
              state: 'YES',
            ));
            Notificationed.showNotification(
                    title: '${alarm.creator} says ${alarm.title}',
                    body: 'TAP TO STOP PLAYING')
                .then((value) async {
              final play = BackgroundAudio();

              play.playBackgroundAudio(alarm.minute, alarm.audioPath);
            });
          }
        }
      }
    }

    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}
