import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_alarms_state.dart';
part 'create_alarms_cubit.freezed.dart';

class CreateAlarmsCubit extends Cubit<CreateAlarmsState> {
  CreateAlarmsCubit() : super(const CreateAlarmsState.initial());

  late List allAlarms = [];

  getUserCreatedalarms() async {
    emit(const CreateAlarmsState.loading());
    await Firebase.initializeApp();
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    var response = await FirebaseFirestore.instance
        .collection("alarms")
        .where('CreateByUserID', isEqualTo: user!.uid)
        .get();

    if (response.docs.isEmpty) {
      emit(const CreateAlarmsState.loaded([]));
    } else {
      List alarms = response.docs;

      List tempHolder = [];

      for (var alarms in alarms) {
        tempHolder.add(alarms.data());
      }

      allAlarms = tempHolder;
      emit(CreateAlarmsState.loaded(allAlarms));
      tempHolder = [];
    }
  }
}
