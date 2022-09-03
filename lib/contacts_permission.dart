import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsPermissions extends StatefulWidget {
  const ContactsPermissions({
    Key? key,
  }) : super(key: key);
  // final List<Contact> contacts;
  @override
  State<ContactsPermissions> createState() => _ContactsPermissionsState();
}

class _ContactsPermissionsState extends State<ContactsPermissions> {
  List<Contact> contacts = [];
  late List<Contact> contactsWithApp = [];
  late List<Contact> contactsWithOutApp = [];
  bool canCreateAlarm = false;
  bool canEditAlarm = false;
  bool candeleteAlarm = false;

  Future<bool> resolveIFCanCreeateAlarm(phoneNumber) async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(testUser)
        .get();

    List userWithPermissionPhones = userData.data()!['canCreate'];
    if (userWithPermissionPhones
        .contains(phoneNumber.replaceAll(RegExp(' '), ''))) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resolveIFCanEditAlarm(phoneNumber) async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(testUser)
        .get();

    List userWithPermissionPhones = userData.data()!['canEdit'];
    if (userWithPermissionPhones
        .contains(phoneNumber.replaceAll(RegExp(' '), ''))) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resolveIFCanDeleteAlarm(phoneNumber) async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(testUser)
        .get();

    List userWithPermissionPhones = userData.data()!['canDelete'];
    if (userWithPermissionPhones
        .contains(phoneNumber.replaceAll(RegExp(' '), ''))) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getAllContactsInPhone();
    getContactsWithApp();
    getContactsWithoutApp();
  }

  getAllContactsInPhone() async {
    List<Contact> phonecontacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = phonecontacts;
    });
  }

  getContactsWithApp() async {
    var userData = await FirebaseFirestore.instance.collection("users").get();
    List allUserPhones = [];
    List allContacts = [];

    for (var userData in userData.docs) {
      allUserPhones.add(userData.data()['phone']);
    }

    for (var contact in contacts) {
      allContacts.add(contact.phones![0].value!.replaceAll(RegExp(' '), ''));
    }

    List userContactsWithApp = allUserPhones
        .where((element) => allContacts.contains(element))
        .toList();

    // print('All contacts from backend: $allUserPhones');
    // print('All contacts from phone: $allContacts');
    // print('User contacts with the app : $userContactsWithApp');

    late List tempHolder = [];
    for (var contact in userContactsWithApp) {
      List<Contact> filtered = contacts
          .where((element) =>
              element.phones![0].value!.replaceAll(RegExp(' '), '') == contact)
          .toList();

      tempHolder.add(filtered);
    }
    for (var contact in tempHolder) {
      setState(() {
        contactsWithApp.add(contact[0]);
      });
    }
  }

  getContactsWithoutApp() async {
    var userData = await FirebaseFirestore.instance.collection("users").get();

    List allUserPhones = [];
    List allContacts = [];

    for (var userData in userData.docs) {
      allUserPhones.add(userData.data()['phone']);
    }

    for (var contact in contacts) {
      allContacts.add(contact.phones![0].value!.replaceAll(RegExp(' '), ''));
    }

    List difference =
        allContacts.toSet().difference(allUserPhones.toSet()).toList();

    late List tempHolder = [];
    for (var contact in difference) {
      List<Contact> filtered = contacts
          .where((element) =>
              element.phones![0].value!.replaceAll(RegExp(' '), '') == contact)
          .toList();

      tempHolder.add(filtered);
    }

    for (var contact in tempHolder) {
      setState(() {
        contactsWithOutApp.add(contact[0]);
      });
    }
  }

  toggleCreateAlarmPermission(phoneNumber, bool value) async {
    print(value);
    print(phoneNumber);

    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canCreate':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canCreate':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  toggleEditAlarmPermission(phoneNumber, bool value) async {
    print(value);
    print(phoneNumber);

    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canEdit':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canEdit':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  toggleDeleteAlarmPermission(phoneNumber, bool value) async {
    print(value);
    print(phoneNumber);

    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canDelete':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(testUser).update({
        'canDelete':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: const [
                Text('These are all your contacts ',
                    style: TextStyle(
                      color: Color(0xCC385A64),
                      fontFamily: 'Skranji',
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: const [
                Text('With Voice notice',
                    style: TextStyle(
                      color: Color(0xCC385A64),
                      fontFamily: 'Skranji',
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ExpansionPanelList.radio(
                dividerColor: Colors.transparent,
                elevation: 0,
                children: contactsWithApp
                    .map((contact) => ExpansionPanelRadio(
                        canTapOnHeader: true,
                        backgroundColor: const Color(0xffF9F9F9),
                        value: contact.phones![0].value!,
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xCC385A64),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: Text(contact.displayName![0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Skranji',
                                        fontSize: 18,
                                      )),
                                )),
                            title: Text('${contact.displayName}',
                                style: const TextStyle(
                                  color: Color(0xFF7689D6),
                                  fontFamily: 'Skranji',
                                  fontSize: 15,
                                )),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(contact.phones![0].value!,
                                  style: const TextStyle(
                                    color: Color(0xCC385A64),
                                    fontFamily: 'Skranji',
                                    fontSize: 15,
                                  )),
                            ),
                          );
                        },
                        body: Container(
                          color: const Color(0xffF9F9F9),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        FutureBuilder<bool>(
                                            future: resolveIFCanCreeateAlarm(
                                                contact.phones![0].value!),
                                            builder: (context, snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  if (snapshot.hasData) {
                                                    return Row(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10.0,
                                                          width: 10.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF7689D6),
                                                            strokeWidth: 2.0,
                                                          ),
                                                        ),
                                                        Checkbox(
                                                            checkColor:
                                                                Colors.white,
                                                            activeColor:
                                                                const Color(
                                                                    0xFF7689D6),
                                                            value:
                                                                snapshot.data,
                                                            onChanged:
                                                                (value) {}),
                                                      ],
                                                    );
                                                  } else {
                                                    return const SizedBox(
                                                      height: 15.0,
                                                      width: 15.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF7689D6),
                                                        strokeWidth: 3.0,
                                                      ),
                                                    );
                                                  }

                                                default:
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        activeColor:
                                                            const Color(
                                                                0xFF7689D6),
                                                        value: snapshot.data,
                                                        onChanged: (value) {
                                                          toggleCreateAlarmPermission(
                                                              contact.phones![0]
                                                                  .value!,
                                                              value!);
                                                        });
                                                  }
                                              }
                                            }),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('Can create Alarm',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        FutureBuilder<bool>(
                                            future: resolveIFCanEditAlarm(
                                                contact.phones![0].value!),
                                            builder: (context, snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  if (snapshot.hasData) {
                                                    return Row(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10.0,
                                                          width: 10.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF7689D6),
                                                            strokeWidth: 2.0,
                                                          ),
                                                        ),
                                                        Checkbox(
                                                            checkColor:
                                                                Colors.white,
                                                            activeColor:
                                                                const Color(
                                                                    0xFF7689D6),
                                                            value:
                                                                snapshot.data,
                                                            onChanged:
                                                                (value) {}),
                                                      ],
                                                    );
                                                  } else {
                                                    return const SizedBox(
                                                      height: 15.0,
                                                      width: 15.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF7689D6),
                                                        strokeWidth: 3.0,
                                                      ),
                                                    );
                                                  }

                                                default:
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        activeColor:
                                                            const Color(
                                                                0xFF7689D6),
                                                        value: snapshot.data,
                                                        onChanged: (value) {
                                                          toggleEditAlarmPermission(
                                                              contact.phones![0]
                                                                  .value!,
                                                              value!);
                                                        });
                                                  }
                                              }
                                            }),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('Can edit Alarm',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 40.0),
                                child: Row(
                                  children: [
                                    Row(
                                      children: [
                                        FutureBuilder<bool>(
                                            future: resolveIFCanDeleteAlarm(
                                                contact.phones![0].value!),
                                            builder: (context, snapshot) {
                                              switch (
                                                  snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  if (snapshot.hasData) {
                                                    return Row(
                                                      children: [
                                                        const SizedBox(
                                                          height: 10.0,
                                                          width: 10.0,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: Color(
                                                                0xFF7689D6),
                                                            strokeWidth: 2.0,
                                                          ),
                                                        ),
                                                        Checkbox(
                                                            checkColor:
                                                                Colors.white,
                                                            activeColor:
                                                                const Color(
                                                                    0xFF7689D6),
                                                            value:
                                                                snapshot.data,
                                                            onChanged:
                                                                (value) {}),
                                                      ],
                                                    );
                                                  } else {
                                                    return const SizedBox(
                                                      height: 15.0,
                                                      width: 15.0,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Color(0xFF7689D6),
                                                        strokeWidth: 3.0,
                                                      ),
                                                    );
                                                  }

                                                default:
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    return Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        activeColor:
                                                            const Color(
                                                                0xFF7689D6),
                                                        value: snapshot.data,
                                                        onChanged: (value) {
                                                          toggleDeleteAlarmPermission(
                                                              contact.phones![0]
                                                                  .value!,
                                                              value!);
                                                        });
                                                  }
                                              }
                                            }),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Text('Can delete Alarm',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )))
                    .toList()),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: const [
                Text('These contacts do not have ',
                    style: TextStyle(
                      color: Color(0xCC385A64),
                      fontFamily: 'Skranji',
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: const [
                Text('Voice Notice installed',
                    style: TextStyle(
                      color: Color(0xCC385A64),
                      fontFamily: 'Skranji',
                      fontSize: 18,
                    )),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: contactsWithOutApp.map((contact) {
              return ListTile(
                leading: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xCC385A64),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      border: Border.all(
                        color: Colors.black12,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(contact.displayName![0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Skranji',
                            fontSize: 18,
                          )),
                    )),
                title: Text('${contact.displayName}',
                    style: const TextStyle(
                      color: Color(0xFF7689D6),
                      fontFamily: 'Skranji',
                      fontSize: 15,
                    )),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(contact.phones![0].value!,
                      style: const TextStyle(
                        color: Color(0xCC385A64),
                        fontFamily: 'Skranji',
                        fontSize: 15,
                      )),
                ),
                trailing: InkWell(
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(
                        'sms:${contact.phones![0].value!}?body=Join Voice Notice to send voice recordings as Alarms to friends');
                  },
                  child: Container(
                      height: 40,
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                          color: Colors.black12,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text('Invite',
                            style: TextStyle(
                              color: Color(0xCCBC343E),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      )),
                ),
              );
            }).toList(),
          )
        ],
      )),
    );
  }
}
