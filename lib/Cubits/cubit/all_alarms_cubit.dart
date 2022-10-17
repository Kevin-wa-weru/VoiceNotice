import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var response = await FirebaseFirestore.instance
        .collection("alarms")
        .where('TargetUserid', isEqualTo: user!.uid)
        .get();

    if (response.docs.isEmpty) {
      _allUSeralarms = [];
      emit(AllAlarmsState.loaded(_allUSeralarms, []));
    } else {
      List alarms = response.docs;

      List tempHolder = [];

      for (var alarms in alarms) {
        tempHolder.add(alarms.data());
      }

      _allUSeralarms = tempHolder;

      List userNames = [];
      for (var alarm in tempHolder) {
        var result = await changeUserName(alarm['createdForPhoneNUmber']);
        if (result == '') {
          userNames.add(alarm['createdForUserName']);
        } else {
          userNames.add(result);
        }
      }

      print('Wjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj $userNames');

      emit(AllAlarmsState.loaded(_allUSeralarms, userNames));
    }
  }

  checkIfAllisDeleted() {
    final AlarmHelper alarmHelper = AlarmHelper();
    alarmHelper.initializeDatabase().then((value) async {
      List uSeralarms = await alarmHelper.getAlarms();
      if (uSeralarms.isEmpty) {
        emit(const AllAlarmsState.loaded([], []));
      } else {
        //do nothing
      }
    });
  }

  changeUserName(phone) async {
    List<Contact> phonecontacts =
        await ContactsService.getContacts(withThumbnails: false);

    List<Contact> user = phonecontacts
        .where((element) =>
            phone.replaceAll(RegExp(' '), '').replaceAll(RegExp('-'), '') ==
            element.phones!.first.value!
                .replaceAll(RegExp(' '), '')
                .replaceAll(RegExp('-'), ''))
        .toList();
    if (user.isEmpty) {
      return '';
    } else {
      return user.first.displayName;
    }
  }
}
