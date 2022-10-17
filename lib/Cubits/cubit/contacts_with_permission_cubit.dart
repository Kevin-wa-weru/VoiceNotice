import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'contacts_with_permission_state.dart';
part 'contacts_with_permission_cubit.freezed.dart';

class ContactsWithPermissionCubit extends Cubit<ContactsWithPermissionState> {
  ContactsWithPermissionCubit()
      : super(const ContactsWithPermissionState.initial());

  late List allContactsWithPermission = [];

  getPhonesWithPermission() async {
    emit(const ContactsWithPermissionState.loading());
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .where('canCreate', arrayContains: user!.phoneNumber);
    docRef.snapshots().listen((event) async {
      for (var userinfo in event.docChanges) {
        debugPrint(userinfo.doc.data().toString());
        var userData = await FirebaseFirestore.instance
            .collection("users")
            .where('canCreate', arrayContains: user.phoneNumber)
            .get();
        for (var user in userData.docs) {
          allContactsWithPermission.add(user.data());
        }
        emit(ContactsWithPermissionState.loaded(allContactsWithPermission));
        allContactsWithPermission = [];
      }
    });
  }
}
