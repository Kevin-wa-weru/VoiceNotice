import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
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
      emit(const CreateAlarmsState.loaded([], []));
    } else {
      List alarms = response.docs;

      List tempHolder = [];

      for (var alarms in alarms) {
        tempHolder.add(alarms.data());
      }

      allAlarms = tempHolder;

      List userNames = [];
      for (var alarm in allAlarms) {
        var result = await changeUserName(alarm['createdByPhoneNUmber']);
        if (result == '') {
          userNames.add(alarm['createdByUserName']);
        } else {
          userNames.add(result);
        }
      }

      emit(CreateAlarmsState.loaded(allAlarms, userNames));
      tempHolder = [];
    }
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
