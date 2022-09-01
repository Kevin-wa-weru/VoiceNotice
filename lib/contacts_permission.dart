import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

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
  bool canCreateAlarm = false;
  bool canEditAlarm = false;
  bool candeleteAlarm = false;

  @override
  void initState() {
    super.initState();
    getAllContacts();
    getContactsWithApp();
  }

  getAllContacts() async {
    List<Contact> phonecontacts =
        await ContactsService.getContacts(withThumbnails: false);
    setState(() {
      contacts = phonecontacts;
    });
  }

  getContactsWithApp() async {
    //First fetch all users

    // var userData = await usersRef.doc(FirebaseServices().getUserId()).get();
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance.collection("users").get();

    List allUserPhones = [];

    for (var userData in userData.docs) {
      allUserPhones.add(userData.data()['phone']);
    }

    print(allUserPhones);
  }

  singleContactPermission(phone) {}

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
                children: contacts
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
                                        Checkbox(
                                            checkColor: Colors.white,
                                            activeColor:
                                                const Color(0xFF7689D6),
                                            value: canCreateAlarm,
                                            onChanged: (value) {
                                              setState(() {
                                                canCreateAlarm = value!;
                                              });
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
                                        Checkbox(
                                            checkColor: Colors.white,
                                            activeColor:
                                                const Color(0xFF7689D6),
                                            value: canEditAlarm,
                                            onChanged: (value) {
                                              setState(() {
                                                canEditAlarm = value!;
                                              });
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
                                        Checkbox(
                                            checkColor: Colors.white,
                                            activeColor:
                                                const Color(0xFF7689D6),
                                            value: candeleteAlarm,
                                            onChanged: (value) {
                                              setState(() {
                                                candeleteAlarm = value!;
                                              });
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
            children: contacts.map((contact) {
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
                trailing: Container(
                    height: 40,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
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
              );
            }).toList(),
          )
        ],
      )),
    );
  }
}
