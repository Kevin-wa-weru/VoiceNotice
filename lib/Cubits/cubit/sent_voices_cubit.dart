import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sent_voices_state.dart';
part 'sent_voices_cubit.freezed.dart';

class SentVoicesCubit extends Cubit<SentVoicesState> {
  SentVoicesCubit() : super(const SentVoicesState.initial());

  late List sentmessages = [];

  getSentMessages() async {
    emit(const SentVoicesState.loading());
    await Firebase.initializeApp();
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var response = await FirebaseFirestore.instance
        .collection("messages")
        .where('CreateByUserID', isEqualTo: user!.uid)
        .get();

    if (response.docs.isEmpty) {
      sentmessages = [];
      emit(SentVoicesState.loaded(sentmessages));
    } else {
      List messages = response.docs;

      List tempHolder = [];

      for (var message in messages) {
        tempHolder.add(message.data());
      }
      sentmessages = tempHolder;
      emit(SentVoicesState.loaded(sentmessages));
    }
  }
}
