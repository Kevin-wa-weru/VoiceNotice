import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:voicenotice/services/alarm_helper.dart';

part 'all_alarms_state.dart';
part 'all_alarms_cubit.freezed.dart';

class AllAlarmsCubit extends Cubit<AllAlarmsState> {
  AllAlarmsCubit() : super(const AllAlarmsState.initial());

  late List _allUSeralarms = [];

  getAllUSeralarms() async {
    emit(const AllAlarmsState.loading());
    await Firebase.initializeApp();
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    var response = await FirebaseFirestore.instance
        .collection("alarms")
        .where('TargetUserid', isEqualTo: testUser)
        .get();

    if (response.docs.isEmpty) {
      _allUSeralarms = [];
      emit(AllAlarmsState.loaded(_allUSeralarms));
    } else {
      List alarms = response.docs;

      List tempHolder = [];

      for (var alarms in alarms) {
        tempHolder.add(alarms.data());
      }

      _allUSeralarms = tempHolder;
      emit(AllAlarmsState.loaded(_allUSeralarms));
    }
  }

  checkIfAllisDeleted() {
    final AlarmHelper alarmHelper = AlarmHelper();
    alarmHelper.initializeDatabase().then((value) async {
      List USeralarms = await alarmHelper.getAlarms();
      if (USeralarms.isEmpty) {
        emit(const AllAlarmsState.loaded([]));
      } else {
        //do nothing
      }
    });
  }
}
