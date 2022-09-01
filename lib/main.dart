import 'package:country_codes/country_codes.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:voicenotice/homepage.dart';
import 'package:voicenotice/models/user_credentials.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/services/hive.dart';
import 'package:voicenotice/set_name.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp();
  await CountryCodes.init();
  Hive.registerAdapter(UserRegAdapter());
  await Hive.openBox<UserReg>('account');
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
      home: userid != null ? const OnboardingScreen() : const HomePage(),
    );
  }
}
