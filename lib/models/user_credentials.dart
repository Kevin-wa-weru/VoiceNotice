// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';

part 'user_credentials.g.dart';

@HiveType(typeId: 0)
class UserReg extends HiveObject {
  @HiveField(1)
  late String userid;
  @HiveField(2)
  late String phone;
  @HiveField(3)
  late String username;
}
