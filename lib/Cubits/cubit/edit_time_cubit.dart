import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_time_state.dart';
part 'edit_time_cubit.freezed.dart';

class EditTimeCubit extends Cubit<EditTimeState> {
  EditTimeCubit() : super(const EditTimeState.initial());

  late int hour = 0;
  late int minute = 0;

  changeTime(int hour, int minute, fileRef) async {
    print('STARTED UPDATING ALARM TIME');
    emit(const EditTimeState.loading());
    await Firebase.initializeApp();

    final CollectionReference alarmRef =
        FirebaseFirestore.instance.collection("alarms");

    late List<dynamic> alarmInfo = [];

    final docRef = await alarmRef
        .where('RecordUrl', isEqualTo: fileRef)
        .get()
        .then((QuerySnapshot snapshot) {
      alarmInfo.add(snapshot.docs.first.data());
      return snapshot.docs[0].id;
    });

    print('THISS  $alarmInfo');
    print('THIS $docRef');

    DateTime dateOfAlarm =
        DateTime.parse(alarmInfo.first['DateTime'].toDate().toString());

    int year = dateOfAlarm.year;

    var month = dateOfAlarm.month.toString().length == 1
        ? '0${dateOfAlarm.month.toString()}'
        : dateOfAlarm.month.toString();

    var day = dateOfAlarm.day.toString().length == 1
        ? '0${dateOfAlarm.day.toString()}'
        : dateOfAlarm.day.toString();

    var hour2 =
        hour.toString().length == 1 ? '0${hour.toString()}' : hour.toString();

    var minute2 = minute.toString().length == 1
        ? '0${minute.toString()}'
        : minute.toString();

    DateTime newDateofAlarm =
        DateTime.parse('$year-$month-${day}T$hour2:$minute2');

    await alarmRef.doc(docRef).update({'DateTime': newDateofAlarm});

    print('FINISHED UPDATING ALARM TIME');
    emit(EditTimeState.loaded(hour, minute));
  }
}
