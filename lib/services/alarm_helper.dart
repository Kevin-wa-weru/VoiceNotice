import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

const String tableAlarm = 'alarm';
const String columnId = 'id';
const String columnTitle = 'title';
const String columnDateTime = 'alarmDateTime';
const String columnHour = 'hour';
const String columnMinute = 'minute';
const String columnCreator = 'creator';
const String columnAudioPath = 'audioPath';
const String columnfileRef = 'fileRef';

const String tableMessage = 'message';
const String columnMessageid = 'id';
const String columnRecordUrl = 'recordUrl';

const String tableAudioState = 'audioState';
const String columnAudioId = 'idi';
const String columnAudioConstName = 'constName';
const String columnAudioState = 'state';

const String tableUserName = 'userName';
const String columnUserid = 'idii';
const String columnUserNameID = 'userID';

class AlarmHelper {
  static Database? _database;
  static AlarmHelper? _alarmHelper;

  AlarmHelper._createInstance();
  factory AlarmHelper() {
    // ignore: prefer_conditional_assignment
    if (_alarmHelper == null) {
      _alarmHelper = AlarmHelper._createInstance();
    }
    return _alarmHelper!;
  }

  Future<Database> get database async {
    // ignore: prefer_conditional_assignment
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = "${dir}alarm.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnDateTime text not null,
          $columnHour integer not null,
          $columnMinute integer not null,
          $columnCreator text not null,
          $columnAudioPath text not null,
          $columnfileRef text not null)
        ''');
        await db.execute('''
          create table $tableAudioState ( 
          $columnAudioId integer primary key autoincrement, 
          $columnAudioConstName text not null,
          $columnAudioState text not null)
        ''');
        await db.execute('''
          create table $tableMessage ( 
          $columnMessageid integer primary key autoincrement, 
          $columnRecordUrl text not null)
        ''');
      },
    );
    return database;
  }

  void insertUserName(UserName userInfo) async {
    // ignore: unnecessary_this
    var db = await this.database;
    await db.insert(tableUserName, userInfo.toMap());
  }

  void insertAlarm(AlarmInfo alarmInfo) async {
    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    debugPrint('result IN ALARM HELPER : $result');
  }

  void insertAudioState(PlayerStating playerState) async {
    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.insert(tableAudioState, playerState.toMap());
    debugPrint('result IN ALARM HELPER AUDIO STATE : $result');
  }

  void insertMessage(MessageInfo message) async {
    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.insert(tableMessage, message.toMap());
    debugPrint('result IN ALARM HELPER AUDIO STATE : $result');
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> alarms = [];

    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.query(tableAlarm);
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      alarms.add(alarmInfo);
    });

    return alarms;
  }

  Future<List<MessageInfo>> getMessages() async {
    List<MessageInfo> messages = [];

    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.query(tableMessage);
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((element) {
      var messageInfo = MessageInfo.fromMap(element);
      messages.add(messageInfo);
    });

    return messages;
  }

  Future<List<PlayerStating>> getAudioState() async {
    List<PlayerStating> audioState = [];

    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.query(tableAudioState);
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((element) {
      var audioInfo = PlayerStating.fromMap(element);
      audioState.add(audioInfo);
    });

    return audioState;
  }

  Future<List<UserName>> getUserName() async {
    List<UserName> userINFOMATION = [];

    // ignore: unnecessary_this
    var db = await this.database;
    var result = await db.query(tableUserName);
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((element) {
      var userNameInfo = UserName.fromMap(element);
      userINFOMATION.add(userNameInfo);
    });

    return userINFOMATION;
  }

  Future<int> deleteAudioState(String columname) async {
    // ignore: unnecessary_this
    var db = await this.database;
    return await db.delete(tableAudioState,
        where: '$columnAudioConstName = ?', whereArgs: [columname]);
  }

  Future<int> delete(String? fileRef) async {
    // ignore: unnecessary_this
    var db = await this.database;
    return await db
        .delete(tableAlarm, where: '$columnfileRef = ?', whereArgs: [fileRef]);
  }

  Future<bool> checkIfAlarmExists(fileRef) async {
    // ignore: unnecessary_this
    var db = await this.database;
    var queryResult = await db
        .rawQuery('SELECT * FROM $tableAlarm WHERE $columnfileRef="$fileRef"');

    if (queryResult.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> checkIfMessageExists(recordRef) async {
    // ignore: unnecessary_this
    var db = await this.database;
    var queryResult = await db.rawQuery(
        'SELECT * FROM $tableMessage WHERE $columnRecordUrl="$recordRef"');

    if (queryResult.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future updateAudioState(String playAudio, String columname) async {
    // ignore: unnecessary_this
    var db = await this.database;
    await db.rawUpdate('''
    UPDATE $tableAudioState 
    SET $columnAudioState = ?
    WHERE $columnAudioConstName = ?
    ''', [playAudio, columname]);
  }

  Future updateAlarm(hour, minute, fileRef) async {
    // ignore: unnecessary_this
    var db = await this.database;
    await db.rawUpdate('''
    UPDATE $tableAlarm 
    SET $columnHour = ?, $columnMinute = ?
    WHERE $columnfileRef = ?
    ''', [hour, minute, fileRef]);
  }
}

class AlarmInfo {
  int? id;
  String? title;
  DateTime? alarmDateTime;
  String? creator;
  String? audioPath;
  String? fileRef;
  int? hour;
  int? minute;

  AlarmInfo({
    this.id,
    this.title,
    this.alarmDateTime,
    this.creator,
    this.audioPath,
    this.fileRef,
    this.hour,
    this.minute,
  });

  factory AlarmInfo.fromMap(Map<String, dynamic> json) => AlarmInfo(
        id: json["id"],
        title: json["title"],
        alarmDateTime: DateTime.parse(json["alarmDateTime"]),
        creator: json["creator"],
        audioPath: json["audioPath"],
        fileRef: json["fileRef"],
        hour: json["hour"],
        minute: json["minute"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "alarmDateTime": alarmDateTime!.toIso8601String(),
        "creator": creator,
        "audioPath": audioPath,
        "fileRef": fileRef,
        "hour": hour,
        "minute": minute,
      };
}

class MessageInfo {
  int? id;
  String? recordUrl;

  MessageInfo({
    this.id,
    this.recordUrl,
  });

  factory MessageInfo.fromMap(Map<String, dynamic> json) => MessageInfo(
        id: json["id"],
        recordUrl: json["recordUrl"],
      );
  Map<String, dynamic> toMap() => {
        "id": id,
        "recordUrl": recordUrl,
      };
}

class PlayerStating {
  int? idi;
  String? constName;
  String? state;

  PlayerStating({
    this.idi,
    this.constName,
    this.state,
  });

  factory PlayerStating.fromMap(Map<String, dynamic> json) => PlayerStating(
        idi: json["idi"],
        constName: json["constName"],
        state: json["state"],
      );
  Map<String, dynamic> toMap() => {
        "idi": idi,
        "constName": constName,
        "state": state,
      };
}

class UserName {
  int? idi;
  String? userID;

  UserName({
    this.idi,
    this.userID,
  });

  factory UserName.fromMap(Map<String, dynamic> json) => UserName(
        idi: json["idii"],
        userID: json["userID"],
      );
  Map<String, dynamic> toMap() => {
        "idii": userID,
        "userID": userID,
      };
}
