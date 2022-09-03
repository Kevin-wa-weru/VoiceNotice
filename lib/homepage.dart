import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicenotice/contacts_permission.dart';
import 'package:voicenotice/created_alarms.dart';
import 'package:voicenotice/models/user_alarms.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/record.dart';
import 'package:voicenotice/services/alarm_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AlarmInfo>? _allAlarms;
  final AlarmHelper _alarmHelper = AlarmHelper();
  List? usersWithPermission = [];

  getContactsWithPermission() async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(testUser)
        .get();

    print(userData.data());

    List userWithPermissionPhones = userData.data()!['canCreate'];

    print('userWithPermissionIDS');
    print(userWithPermissionPhones);

    //Then get all users info with permission

    List tempHolder = [];

    for (var user in userWithPermissionPhones) {
      var response = await FirebaseFirestore.instance
          .collection("users")
          .where('phone', isEqualTo: user)
          .get();
      tempHolder.add(response.docs);
    }

    print('Temp Holder: $tempHolder');

    for (var user in tempHolder) {
      usersWithPermission!.add(user[0].data());
    }

    print('usersWithPermission');
    print(usersWithPermission);
  }

  Future<void> _askContactsPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      print('Permision given');
      await _getStoragePermission();
    } else {
      _handleInvalidPermissions(permissionStatus);
      await _getStoragePermission();
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      const snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      const snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      const snackBar =
          SnackBar(content: Text('Access to storage data accepted'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      const snackBar = SnackBar(content: Text('Access to storage data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    _askContactsPermissions('');
    getContactsWithPermission();
    _alarmHelper.initializeDatabase().then((value) => loadAlarms());
  }

  Future<List<AlarmInfo>?> loadAlarms() async {
    _allAlarms = await _alarmHelper.getAlarms();
    // if (mounted) setState(() {});
    print('ALL ALARMS ======= $_allAlarms');
    return _allAlarms;
  }

  void modalBottomSheetMenu() {
    showModalBottomSheet(
        backgroundColor: const Color(0xFFF9F9F9),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(70),
          ),
        ),
        context: context,
        builder: (builder) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(70),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset('assets/icons/cancel.svg',
                              height: 6,
                              color: Colors.black,
                              fit: BoxFit.fitHeight),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 10.0,
                  ),
                  child: Center(
                    child: Text('Select from these contacts',
                        style: TextStyle(
                          color: Color(0xFF7689D6),
                          fontFamily: 'Skranji',
                          fontSize: 18,
                        )),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Center(
                    child: Text('They have given you permission',
                        style: TextStyle(
                          color: Color(0xFFBC343E),
                          fontFamily: 'Skranji',
                          fontSize: 18,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                      children: usersWithPermission!
                          .map(
                            (user) => SingleContact(
                              user: user,
                            ),
                          )
                          .toList()),
                ),
              ],
            ),
          );
        });
  }

  int currentIndex = 0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final listKey = GlobalKey<AnimatedListState>();

  void removeItem(int index, alarmIDinDB, date) async {
    final player = AudioPlayer();

    await player.play(AssetSource('delete.wav'));

    final removedItem = _allAlarms![index];

    allUserAlarms.removeAt(index);
    listKey.currentState!.removeItem(
      index,
      (context, animation) => ListItemWidget(
        item: removedItem,
        animation: animation,
        onClicked: () {},
      ),
      duration: const Duration(milliseconds: 500),
    );

    //Remove from loal DB
    _alarmHelper.delete(alarmIDinDB);
    //REmove from firebase
    var collection = FirebaseFirestore.instance.collection('alarms');
    var snapshot = await collection
        .where('DateTime', isEqualTo: Timestamp.fromDate(date))
        .get();
    await snapshot.docs.first.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7689D6),
        onPressed: () {
          modalBottomSheetMenu();
        },
        child: SizedBox(
          height: 20,
          width: 20,
          child: SvgPicture.asset('assets/icons/add.svg',
              color: Colors.white, fit: BoxFit.fitHeight),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Builder(
                builder: (context) => IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/drawer.svg",
                    height: 15,
                    width: 34,
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            const Text('VOICE NOTICE',
                style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Skranji',
                  fontSize: 25,
                )),
          ],
        ),
        backgroundColor: currentIndex == 3
            ? const Color(0xffF9F9F9)
            : const Color(0xffF9F9F9),
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width / 1.25,
        child: Drawer(
          backgroundColor: const Color(0xffF9F9F9),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SizedBox(
                  height: 400.25,
                  width: 400.5,
                  child: SvgPicture.asset('assets/images/img13.svg',
                      fit: BoxFit.fitHeight),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'My Alarms',
                  style: TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Created Alarms',
                  style: TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 2;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Permissions',
                  style: TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const OnboardingScreen();
                  }));
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xCC385A64),
                    fontFamily: 'Skranji',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Material(
                borderRadius: BorderRadius.circular(500),
                child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  splashColor: const Color(0xCC385A64),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xCC385A64),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 65,
                  width: MediaQuery.of(context).size.width,
                  color: const Color(0xCC385A64),
                  child: const Center(
                    child: Text(
                      'Voice Notice v1.0.1',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Skranji',
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ))
            ],
          ),
        ),
      ),
      body: <Widget>[
        Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const TopBanner(),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Container(
                height: 0.7,
                color: Colors.black12,
              ),
            ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Row(
            //   children: const [
            //     Padding(
            //       padding: EdgeInsets.only(left: 50.0),
            //       child: Text('Your Alarms',
            //           style: TextStyle(
            //             color: Color(0xCC385A64),
            //             fontFamily: 'Skranji',
            //             fontSize: 20,
            //             fontWeight: FontWeight.w600,
            //           )),
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 20,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
            //   child: Container(
            //     height: 0.7,
            //     color: Colors.black12,
            //   ),
            // ),
            FutureBuilder<List<AlarmInfo>?>(
                future: loadAlarms(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                  } else {
                    return const Center(
                      child: Text('NO alarms have been created fro you'),
                    );
                  }

                  return Expanded(
                    child: AnimatedList(
                        key: listKey,
                        initialItemCount: snapshot.data!.length,
                        itemBuilder: (context, index, animation) {
                          return ListItemWidget(
                              item: snapshot.data![index],
                              animation: animation,
                              onClicked: () {
                                removeItem(index, snapshot.data![index].id,
                                    snapshot.data![index].alarmDateTime);
                              });
                        }),
                  );
                }),
          ],
        ),
        const CreatedAlarms(),
        const ContactsPermissions(),
        const OnboardingScreen(),
      ][currentIndex],
    );
  }
}

// ignore: must_be_immutable
class ListItemWidget extends StatefulWidget {
  final AlarmInfo item;
  final Animation<double> animation;
  final VoidCallback? onClicked;
  const ListItemWidget(
      {Key? key, required this.item, required this.animation, this.onClicked})
      : super(key: key);

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  TimeOfDay _time = TimeOfDay.now().replacing(hour: 11, minute: 30);

  bool iosStyle = true;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.animation,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Center(
              child: Card(
                elevation: 5,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                    //  bottomRight: Radius.circular(40),
                  ),
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.width - 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      // bottomRight: Radius.circular(40),
                    ),
                    border: Border.all(
                      color: Colors.black12,
                      width: 0,
                      // 1.5
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                ),
                                child: Row(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0.0, -35.0),
                                      child: Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            color: const Color(0xCC385A64),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                              color: Colors.black12, width: 4,
                                              // 1.5
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(widget.item.creator!,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Skranji',
                                                  fontSize: 18,
                                                )),
                                          )),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0.0, -15.0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(widget.item.title!,
                                                style: const TextStyle(
                                                  color: Color(0x991A1314),
                                                  fontFamily: 'Skranji',
                                                  fontSize: 18,
                                                )),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: SvgPicture.asset(
                                                  'assets/icons/alarm.svg',
                                                  height: 6,
                                                  color: Colors.black,
                                                  fit: BoxFit.fitHeight),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, -15.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    right: 20.0,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        showPicker(
                                          borderRadius: 15,
                                          iosStylePicker: true,
                                          unselectedColor:
                                              const Color(0xCC385A64),
                                          accentColor: const Color(0xFF7689D6),
                                          okStyle: const TextStyle(
                                            color: Color(0xFF7689D6),
                                            fontFamily: 'Skranji',
                                            fontSize: 18,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          okText: 'Okay',
                                          cancelStyle: const TextStyle(
                                            color: Color(0xFFBC343E),
                                            fontFamily: 'Skranji',
                                            fontSize: 18,
                                            // fontWeight: FontWeight.w600,
                                          ),
                                          blurredBackground: true,
                                          context: context,
                                          value: _time,
                                          onChange: onTimeChanged,
                                          minuteInterval: MinuteInterval.ONE,
                                          // Optional onChange to receive value as DateTime
                                          onChangeDateTime:
                                              (DateTime dateTime) {
                                            // print(dateTime);
                                            debugPrint(
                                                "[debug datetime]:  $dateTime");
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text('Edit Time',
                                        style: TextStyle(
                                          color: Color(0xFFBC343E),
                                          fontFamily: 'Skranji',
                                          fontSize: 18,
                                          // fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(0.0, -23.0),
                            child: Row(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20.0, top: 5),
                                  child: Row(
                                    children: [
                                      Text(
                                          '${widget.item.alarmDateTime!.hour} : ${widget.item.alarmDateTime!.minute}',
                                          style: const TextStyle(
                                            color: Color(0xFF7689D6),
                                            fontFamily: 'Skranji',
                                            fontSize: 28,
                                          )),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                          DateFormat('EEEE')
                                              .format(
                                                  widget.item.alarmDateTime!)
                                              .toString(),
                                          style: const TextStyle(
                                            color: Color(0xFF385A64),
                                            fontFamily: 'Skranji',
                                            fontSize: 18,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0.0, -10.0),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Row(
                                children: [
                                  Text(
                                      '${widget.item.creator!} Created this alarm for you',
                                      style: const TextStyle(
                                        color: Color(0xFF385A64),
                                        fontFamily: 'Skranji',
                                        fontSize: 18,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            print('Clicked');
                            setState(() {
                              widget.onClicked!();
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: const BoxDecoration(
                              color: Color(0x407689D6),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: SvgPicture.asset(
                                      'assets/icons/bin.svg',
                                      height: 6,
                                      color: Colors.black,
                                      fit: BoxFit.fitHeight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingleContact extends StatelessWidget {
  const SingleContact({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Map<String, dynamic> user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10.0, right: 50, left: 50, top: 10.0),
      child: OpenContainer(
        closedColor: const Color(0xFFF9F9F9),
        closedElevation: 0,
        transitionDuration: const Duration(seconds: 1),
        openBuilder: (BuildContext context, _) => RecordingPage(
          user: user,
        ),
        closedBuilder: (context, VoidCallback openContainer) {
          return InkWell(
            onTap: openContainer,
            child: Container(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  border: Border.all(
                    color: const Color(0x0D000000),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xCC385A64),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                            border: Border.all(
                              color: Colors.black12, width: 4,
                              // 1.5
                            ),
                          ),
                          child: Center(
                            child: Text('${user['userName'][0]}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Skranji',
                                  fontSize: 18,
                                )),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      Text('${user['userName']}',
                          style: const TextStyle(
                            color: Color(0xCC385A64),
                            fontFamily: 'Skranji',
                            fontSize: 18,
                          )),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}

class TopBanner extends StatelessWidget {
  const TopBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
            bottomLeft: Radius.circular(40),
            //  bottomRight: Radius.circular(40),
          ),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.22,
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              // bottomRight: Radius.circular(40),
            ),
            border: Border.all(
              color: Colors.black12,
              width: 0,
              // 1.5
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10),
                        child: Text('Top of the Morning',
                            style: TextStyle(
                              color: Color(0xFF7689D6),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30.0, top: 10),
                        child: SizedBox(
                          height: 15.0,
                          width: 15.0,
                          child: SvgPicture.asset(
                            'assets/icons/cancel.svg',
                            // color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 5),
                        child: Text('Kevin',
                            style: TextStyle(
                              color: Color(0xFF7689D6),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Container(
                          color: Colors.white,
                          height: 70,
                          width: 200,
                          child: Column(
                            children: [
                              const Text('Create a voice reminder ',
                                  style: TextStyle(
                                    color: Color(0xCC385A64),
                                    fontFamily: 'Skranji',
                                    fontSize: 18,
                                  )),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: const [
                                  Text('for your friends ',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          color: Colors.white,
                          height: 90,
                          width: 100,
                          child: Image.asset(
                            "assets/images/gif2.gif",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.22,
                  width: 200,
                  decoration: const BoxDecoration(
                    color: Color(0x0D7689D6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(200),
                      topRight: Radius.circular(43),
                      // bottomLeft: Radius.circular(37),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
