import 'package:hive/hive.dart';
import 'package:voicenotice/models/user_credentials.dart';

class Boxes {
  static Box<UserReg> getAccount() => Hive.box('account');
}