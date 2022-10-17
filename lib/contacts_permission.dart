import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_without_app_cubit.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
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
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
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
    // String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    List userWithPermissionPhones = userData.data()!['canDelete'];
    if (userWithPermissionPhones
        .contains(phoneNumber.replaceAll(RegExp(' '), ''))) {
      return true;
    } else {
      return false;
    }
  }

  Future toggleCreateAlarmPermission(phoneNumber, bool value) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canCreate':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canCreate':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  toggleEditAlarmPermission(phoneNumber, bool value) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canEdit':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canEdit':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  toggleDeleteAlarmPermission(phoneNumber, bool value) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (value == true) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canDelete':
            FieldValue.arrayUnion([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }

    if (value == false) {
      final CollectionReference userRef =
          FirebaseFirestore.instance.collection("users");

      await userRef.doc(user!.uid).update({
        'canDelete':
            FieldValue.arrayRemove([phoneNumber.replaceAll(RegExp(' '), '')])
      });

      setState(() {});
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isFetching = false;
  void _onRefresh() async {
    setState(() {
      isFetching = true;
    });
    // await Future.delayed(const Duration(milliseconds: 1000));
    await context.read<ContactsWithAppCubit>().getContactsWithApp();
    // ignore: use_build_context_synchronously
    await context.read<ContactsWithoutAppCubit>().getContactsWithoutApp();
    setState(() {
      isFetching = false;
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    if (isFetching == true) {
    } else {
      setState(() {});
      _refreshController.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: const WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
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
            BlocBuilder<ContactsWithAppCubit, ContactsWithAppState>(
              builder: (context, state) {
                return state.when(
                    initial: () {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color(0xCC385A64),
                        strokeWidth: 5,
                      ));
                    },
                    loading: () {
                      return const Center(
                          child: CircularProgressIndicator(
                        color: Color(0xCC385A64),
                        strokeWidth: 5,
                      ));
                    },
                    loaded: (contactsWithInstalledApp) {
                      contactsWithApp = contactsWithInstalledApp;

                      if (contactsWithApp.isEmpty) {
                        return Container();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ExpansionPanelList.radio(
                              dividerColor: Colors.transparent,
                              elevation: 0,
                              children: contactsWithInstalledApp
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
                                                color: Colors.green,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(100)),
                                                border: Border.all(
                                                  color: Colors.black12,
                                                  width: 4,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                    contact.displayName![0],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'Skranji',
                                                      fontSize: 18,
                                                    )),
                                              )),
                                          title: Row(
                                            children: [
                                              Text('${contact.displayName}',
                                                  style: const TextStyle(
                                                    color: Colors.black54,
                                                    fontFamily: 'Skranji',
                                                    fontSize: 15,
                                                  )),
                                            ],
                                          ),
                                          subtitle: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child:
                                                Text(contact.phones![0].value!,
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
                                              padding: const EdgeInsets.only(
                                                  left: 40.0),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      FutureBuilder<bool>(
                                                          future:
                                                              resolveIFCanCreeateAlarm(
                                                                  contact
                                                                      .phones![
                                                                          0]
                                                                      .value!),
                                                          builder: (context,
                                                              snapshot) {
                                                            switch (snapshot
                                                                .connectionState) {
                                                              case ConnectionState
                                                                  .waiting:
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) async {
                                                                        await toggleCreateAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value:
                                                                          false,
                                                                      onChanged:
                                                                          (value) async {
                                                                        await toggleCreateAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }

                                                              default:
                                                                if (snapshot
                                                                    .hasError) {
                                                                  return Text(
                                                                      'Error: ${snapshot.error}');
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) async {
                                                                        await toggleCreateAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }
                                                            }
                                                          }),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                          'Can create Alarm',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xCC385A64),
                                                            fontFamily:
                                                                'Skranji',
                                                            fontSize: 18,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 40.0),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      FutureBuilder<bool>(
                                                          future:
                                                              resolveIFCanEditAlarm(
                                                                  contact
                                                                      .phones![
                                                                          0]
                                                                      .value!),
                                                          builder: (context,
                                                              snapshot) {
                                                            switch (snapshot
                                                                .connectionState) {
                                                              case ConnectionState
                                                                  .waiting:
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleEditAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value:
                                                                          false,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleEditAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }

                                                              default:
                                                                if (snapshot
                                                                    .hasError) {
                                                                  return Text(
                                                                      'Error: ${snapshot.error}');
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleEditAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }
                                                            }
                                                          }),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                          'Can edit Alarm',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xCC385A64),
                                                            fontFamily:
                                                                'Skranji',
                                                            fontSize: 18,
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 40.0),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      FutureBuilder<bool>(
                                                          future:
                                                              resolveIFCanDeleteAlarm(
                                                                  contact
                                                                      .phones![
                                                                          0]
                                                                      .value!),
                                                          builder: (context,
                                                              snapshot) {
                                                            switch (snapshot
                                                                .connectionState) {
                                                              case ConnectionState
                                                                  .waiting:
                                                                if (snapshot
                                                                    .hasData) {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleDeleteAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value:
                                                                          false,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleDeleteAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }

                                                              default:
                                                                if (snapshot
                                                                    .hasError) {
                                                                  return Text(
                                                                      'Error: ${snapshot.error}');
                                                                } else {
                                                                  return Checkbox(
                                                                      checkColor:
                                                                          Colors
                                                                              .white,
                                                                      activeColor:
                                                                          Colors
                                                                              .yellow,
                                                                      value: snapshot
                                                                          .data,
                                                                      onChanged:
                                                                          (value) {
                                                                        toggleDeleteAlarmPermission(
                                                                            contact.phones![0].value!,
                                                                            value!);
                                                                      });
                                                                }
                                                            }
                                                          }),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                          'Can delete Alarm',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xCC385A64),
                                                            fontFamily:
                                                                'Skranji',
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
                        );
                      }
                    },
                    error: (String message) => Center(
                          child: Text(message),
                        ));
              },
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
            BlocBuilder<ContactsWithoutAppCubit, ContactsWithoutAppState>(
              builder: (context, state) {
                return state.when(
                  initial: () {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(0xCC385A64),
                      strokeWidth: 5,
                    ));
                  },
                  loading: () {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Color(0xCC385A64),
                      strokeWidth: 5,
                    ));
                  },
                  loaded: (contactsNotInstalled) {
                    contactsWithOutApp = contactsNotInstalled;
                    if (contactsWithOutApp.isEmpty) {
                      return Container();
                    } else {
                      return Column(
                        children: contactsNotInstalled.map((contact) {
                          return ListTile(
                            leading: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green,
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
                                  color: Colors.black54,
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
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
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
                      );
                    }
                  },
                  error: (String message) => Center(
                    child: Text(message),
                  ),
                );
              },
            )
          ],
        )),
      ),
    );
  }
}
