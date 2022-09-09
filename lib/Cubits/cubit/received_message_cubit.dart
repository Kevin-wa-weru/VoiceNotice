import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'received_message_state.dart';
part 'received_message_cubit.freezed.dart';

class ReceivedMessageCubit extends Cubit<ReceivedMessageState> {
  ReceivedMessageCubit() : super(const ReceivedMessageState.initial());

  late List receivedmessages = [];

  getReceivedMessages() async {
    emit(const ReceivedMessageState.loading());
    await Firebase.initializeApp();
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var response = await FirebaseFirestore.instance
        .collection("messages")
        .where('TargetUserid', isEqualTo: user!.uid)
        .get();

    if (response.docs.isEmpty) {
      receivedmessages = [];
      emit(ReceivedMessageState.loaded(receivedmessages));
    } else {
      List messages = response.docs;

      List tempHolder = [];

      for (var message in messages) {
        tempHolder.add(message.data());
      }
      receivedmessages = tempHolder;
      emit(ReceivedMessageState.loaded(receivedmessages));
    }
  }
}
