import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'contacts_without_app_state.dart';
part 'contacts_without_app_cubit.freezed.dart';

class ContactsWithoutAppCubit extends Cubit<ContactsWithoutAppState> {
  ContactsWithoutAppCubit() : super(const ContactsWithoutAppState.initial());

  late List<Contact> contactsWithOutApp = [];
  late List<Contact> contacts = [];

  getContactsWithoutApp() async {
    emit(const ContactsWithoutAppState.loading());
    List<Contact> phonecontacts =
        await ContactsService.getContacts(withThumbnails: false);

    contacts = phonecontacts;

    var userData = await FirebaseFirestore.instance.collection("users").get();

    List allUserPhones = [];
    List allContacts = [];

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

    List difference =
        allContacts.toSet().difference(allUserPhones.toSet()).toList();

    late List tempHolder = [];
    for (var contact in difference) {
      List<Contact> tempHoldery =
          contacts.where((element) => element.phones!.isNotEmpty).toList();
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
      contactsWithOutApp.add(contact[0]);
    }
    emit(ContactsWithoutAppState.loaded(contactsWithOutApp));
    contactsWithOutApp = [];
  }
}
