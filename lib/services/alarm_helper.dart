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

const String tableAudioState = 'audioState';
const String columnAudioId = 'idi';
const String columnAudioConstName = 'constName';
const String columnAudioState = 'state';

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
      },
    );
    return database;
  }

  void insertAlarm(AlarmInfo alarmInfo) async {
    var db = await this.database;
    var result = await db.insert(tableAlarm, alarmInfo.toMap());
    print('result IN ALARM HELPER : $result');
  }

  void insertAudioState(PlayerStating playerState) async {
    var db = await this.database;
    var result = await db.insert(tableAudioState, playerState.toMap());
    print('result IN ALARM HELPER AUDIO STATE : $result');
  }

  Future<List<AlarmInfo>> getAlarms() async {
    List<AlarmInfo> _alarms = [];

    var db = await this.database;
    var result = await db.query(tableAlarm);
    result.forEach((element) {
      var alarmInfo = AlarmInfo.fromMap(element);
      _alarms.add(alarmInfo);
    });

    return _alarms;
  }

  Future<List<PlayerStating>> getAudioState() async {
    List<PlayerStating> _audioState = [];

    var db = await this.database;
    var result = await db.query(tableAudioState);
    result.forEach((element) {
      var audioInfo = PlayerStating.fromMap(element);
      _audioState.add(audioInfo);
    });

    return _audioState;
  }

  Future<int> deleteAudioState(String columname) async {
    var db = await this.database;
    return await db.delete(tableAudioState,
        where: '$columnAudioConstName = ?', whereArgs: [columname]);
  }

  Future<int> delete(String? fileRef) async {
    var db = await this.database;
    return await db
        .delete(tableAlarm, where: '$columnfileRef = ?', whereArgs: [fileRef]);
  }

  Future<bool> checkIfAlarmExists(fileRef) async {
    var db = await this.database;
    var queryResult = await db
        .rawQuery('SELECT * FROM $tableAlarm WHERE $columnfileRef="$fileRef"');

    if (queryResult.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future updateAudioState(String playAudio, String columname) async {
    var db = await this.database;
    await db.rawUpdate('''
    UPDATE $tableAudioState 
    SET $columnAudioState = ?
    WHERE $columnAudioConstName = ?
    ''', [playAudio, columname]);
  }

  Future updateAlarm(hour, minute, fileRef) async {
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



// db.execute('CREATE TABLE $tableAlarm($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT, $columnDateTime TEXT, $columnHour INTEGER, $columnMinute INTEGER ,$columnCreator TEXT, $columnAudioPath TEXT, $columnfileRef TEXT)');
//   db.execute('CREATE TABLE $database($columnAudioId INTEGER PRIMARY KEY, $columnAudioConstName TEXT, $columnAudioState TEXT )');
   
