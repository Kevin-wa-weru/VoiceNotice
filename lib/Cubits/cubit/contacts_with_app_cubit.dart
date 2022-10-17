import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_with_app_state.dart';
part 'contacts_with_app_cubit.freezed.dart';

class ContactsWithAppCubit extends Cubit<ContactsWithAppState> {
  ContactsWithAppCubit() : super(const ContactsWithAppState.initial());
  late List allContactsWithApp = [];
  late List<Contact> contacts = [];
  late List<Contact> contactsWithApp = [];
  late List<Contact> contactsWithOutApp = [];

  getContactsWithApp() async {
    emit(const ContactsWithAppState.loading());
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    List<Contact> phonecontacts =
        await ContactsService.getContacts(withThumbnails: false);

    contacts = phonecontacts;

    if (phonecontacts.isEmpty) {
      emit(const ContactsWithAppState.loaded([]));
    } else {
      debugPrint('CONTACTSSSSS:;:::::;$contacts');
      for (int i = 0; i < contacts.length; i++) {
        final docRef = FirebaseFirestore.instance.collection("users");

        docRef.snapshots().listen((event) async {
          var userData =
              await FirebaseFirestore.instance.collection("users").get();
          late List allUserPhones = [];
          late List allContacts = [];

          for (var userData in userData.docs) {
            allUserPhones.add(userData.data()['phone']);
          }

          for (var contact in contacts) {
            if (contact.phones!.isEmpty) {
            } else {
              allContacts.add(contact.phones![0].value!
                  .replaceAll(RegExp(' '), '')
                  .replaceAll(RegExp('-'), ''));
            }
          }

          List userContactsWithApp = allUserPhones
              .where((element) => allContacts.contains(element))
              .toList();

          debugPrint('All contacts from backend: $allUserPhones');
          debugPrint('All contacts from phone: $allContacts');
          debugPrint('User contacts with the app : $userContactsWithApp');

          late List tempHolder = [];
          for (var contact in userContactsWithApp) {
            List<Contact> tempHoldery = contacts
                .where((element) => element.phones!.isNotEmpty)
                .toList();
            List<Contact> filtered = tempHoldery
                .where((element) =>
                    element.phones![0].value!
                        .replaceAll(RegExp(' '), '')
                        .replaceAll(RegExp('-'), '') ==
                    contact)
                .toList();

            tempHolder.add(filtered);
          }
          for (var contact in tempHolder) {
            contactsWithApp.add(contact[0]);
          }

          // ignore: avoid_print
          print('CONTACTSSSSSSS WITH APP:::::$contactsWithApp');

          emit(ContactsWithAppState.loaded(contactsWithApp));

          contactsWithApp = [];
        });
      }
    }
  }
}
