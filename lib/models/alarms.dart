// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';

part 'alarms.g.dart';

@HiveType(typeId: 1)
class AudioStatus extends HiveObject {
  @HiveField(1)
  late bool playAudio;
}
