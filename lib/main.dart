import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voicenotice/Cubits/cubit/all_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicenotice/homepage.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/services/alarm_helper.dart';
import 'package:voicenotice/services/background_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:voicenotice/services/notifications.dart';
import 'Cubits/cubit/create_alarms_cubit.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

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

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    late String userid = '';
    if (user == null) {
      userid = '';
    } else {
      userid = user.uid;
    }

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

// BACKGROUND SERVICES

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();

  return true;
}

void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  // final player = AudioPlayer();
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

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

  // bring to foreground
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }
    late String userid = '';
    await Firebase.initializeApp();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      userid = '';
    } else {
      userid = user.uid;
    }

    debugPrint(
        'BACKGROUND:::: USER HAS NO ALARMS SSDSDSDSDSDSDSDSDSDSDSDSDSDSDDSDSDSSDSDSDSDSDSDSDSDD$userid');
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    if (userid == '') {
      debugPrint('BACKGROUNDDDDDDD NAME:::::::::IS EMPTY');
    } else {
      debugPrint('BACKGROUNDDDDDDD NAME:::::::::$userid');
      var userData = await FirebaseFirestore.instance
          .collection("alarms")
          .where('TargetUserid', isEqualTo: userid)
          .get();

      // ignore: unnecessary_null_comparison
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
          if (DateTime.now().hour == alarm.hour &&
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

    // test using external plugin
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
