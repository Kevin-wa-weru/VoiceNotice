import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:voicenotice/Cubits/mainscreen.dart';
import 'package:voicenotice/homepage.dart';
import 'package:voicenotice/models/user_credentials.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/services/alarm_helper.dart';
import 'package:voicenotice/services/background_audio.dart';
import 'package:voicenotice/services/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:voicenotice/services/notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  await Hive.initFlutter();

  Hive.registerAdapter(UserRegAdapter());
  await Hive.openBox<UserReg>('account');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      const AndroidInitializationSettings('mipmap/ic_launcher');
  var initializationSettingsIOS = const IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) async {
    AlarmHelper _alarmHelper = AlarmHelper();
    _alarmHelper.updateAudioState('NO', 'PANAMA');
    List<PlayerStating> audioState = await _alarmHelper.getAudioState();
    print('TIMETRAVELLING CHANGE NOTIFIERRR:::${audioState.first.state}');
    Timer(const Duration(seconds: 2), () async {
      _alarmHelper.deleteAudioState(audioState.first.constName!);
    });
  });

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = Boxes.getAccount();
    final account = box.values.toList().cast<UserReg>();
    // ignore: prefer_typing_uninitialized_variables
    late var userid;
    if (account.isEmpty) {
      userid = null;
    } else {
      userid = account[0].userid;
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: userid != null ? const OnboardingScreen() : const MainScreen(),
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
  print('FLUTTER BACKGROUND FETCH');

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
  Timer.periodic(const Duration(minutes: 60), (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: "Updated at ${DateTime.now()}",
      );
    }

    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // var userData = await usersRef.doc(FirebaseServices().getUserId()).get();
    await Firebase.initializeApp();
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("alarms")
        .where('TargetUserid', isEqualTo: testUser)
        .get();

    print(userData.docs);
    // ignore: unnecessary_null_comparison
    if (userData.docs.isEmpty) {
      print('BACKGROUND:::: USER HAS NO ALARMS');
    } else {
      print(userData.docs[0].data());

      AlarmHelper _alarmHelper = AlarmHelper();
      _alarmHelper
          .initializeDatabase()
          .then((value) => print('====DATABASE INITIALISED'));

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

      print('MAINNN  ===== $alarms');

      late List filteredAlarms = [];

      for (var alarm in alarms) {
        bool exists = await _alarmHelper.checkIfAlarmExists(alarm['RecordUrl']);

        if (exists) {
          _alarmHelper.updateAlarm(
              DateTime.parse(alarm['DateTime'].toDate().toString()).hour,
              DateTime.parse(alarm['DateTime'].toDate().toString()).minute,
              alarm['RecordUrl']);
        } else {
          filteredAlarms.add(alarm);
        }
      }

      print('MAINNN FILTERED ALARMS  ===== $filteredAlarms');

      if (filteredAlarms.isEmpty) {
        print(
            'BACKGROUNDS:::::::   FILTERED THROUGH LOCAL DB AND FOUND SIMILAR ALARAMS');
      } else {
        late List<AlarmInfo> _alarmInfo = [];
        for (var alarm in filteredAlarms) {
          var alarmInfo = AlarmInfo(
            title: alarm['AlarmTitle'],
            alarmDateTime:
                DateTime.parse(alarm['DateTime'].toDate().toString()),
            hour: DateTime.parse(alarm['DateTime'].toDate().toString()).hour,
            minute:
                DateTime.parse(alarm['DateTime'].toDate().toString()).minute,
            creator: alarm['createdByUserName'],
            audioPath: await saveToLocal(alarm['RecordUrl'], alarm['DateTime']),
            fileRef: alarm['RecordUrl'],
          );
          _alarmInfo.add(alarmInfo);
        }

        for (var alarm in _alarmInfo) {
          print(alarm.creator);
          _alarmHelper.insertAlarm(alarm);
        }
      }

      List<AlarmInfo> alarmsInLocalDB = await _alarmHelper.getAlarms();
      for (var alarm in alarmsInLocalDB) {
        print('BACKGROUND NOTIFICATION:::::::::::::::::${DateTime.now().hour}');
        print(
            'BACKGROUND NOTIFICATION:::::::::::::::::${DateTime.now().minute}');
        print('BACKGROUND NOTIFICATION:::::::::::::::::${alarm.hour}');
        print('BACKGROUND NOTIFICATION:::::::::::::::::${alarm.minute}');
        print('BACKGROUND NOTIFICATION:::::::::::::::::${alarm.audioPath!}');
        if (DateTime.now().hour == alarm.hour &&
            DateTime.now().minute == alarm.minute) {
          _alarmHelper.insertAudioState(PlayerStating(
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
