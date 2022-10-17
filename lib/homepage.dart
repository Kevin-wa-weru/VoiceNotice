import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicenotice/Cubits/cubit/all_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_with_permission_cubit.dart';
import 'package:voicenotice/Cubits/cubit/contacts_without_app_cubit.dart';
import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';
import 'package:voicenotice/contacts_permission.dart';
import 'package:voicenotice/created_alarms.dart';
import 'package:voicenotice/instant_voice.dart';
import 'package:voicenotice/onboarding.dart';
import 'package:voicenotice/record.dart';
import 'package:voicenotice/recording_page2.dart';
import 'package:voicenotice/services/ads.dart';
import 'package:voicenotice/services/alarm_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List allUserAlarms = [];
  final AlarmHelper _alarmHelper = AlarmHelper();
  List? usersWithPermission = [];
  // List<Contact> contacts = [];
  late List<Contact> contactsWithApp = [];

  Future<void> _askContactsPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      // ignore: use_build_context_synchronously
      context.read<AllAlarmsCubit>().getAllUSeralarms();
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
      var snackBar = const SnackBar(
          content: Text(
        'Access to storage denied',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Skranji',
            fontWeight: FontWeight.w500,
            fontSize: 18),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      var snackBar = const SnackBar(
          content: Text(
        'Contact data not available in device',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Skranji',
            fontWeight: FontWeight.w500,
            fontSize: 18),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      // await getPhonesWithPermission();
      context.read<ContactsWithPermissionCubit>().getPhonesWithPermission();
      context.read<ContactsWithAppCubit>().getContactsWithApp();
      context.read<ContactsWithoutAppCubit>().getContactsWithoutApp();
      WidgetsBinding.instance.addObserver(this);
      createBannerAd();
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      var snackBar = const SnackBar(
          content: Text(
        'Access to Storage denied ',
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Skranji',
            fontWeight: FontWeight.w500,
            fontSize: 18),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  late String userName = '';

  getUserName() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    var collection = FirebaseFirestore.instance.collection('users');
    var snapshot = await collection.where('userid', isEqualTo: user!.uid).get();

    var name = await snapshot.docs.first.data()['userName'];

    userName = name;
  }

  late BannerAd bannerad;
  bool isbottomBannerAdLoaded = false;
  @override
  void initState() {
    super.initState();
    getUserName();
    AlarmHelper alarmHelper = AlarmHelper();
    alarmHelper.updateAudioState('NO', 'PANAMA');

    _askContactsPermissions('');
  }

  @override
  void dispose() {
    super.dispose();
    bannerad.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void createBannerAd() {
    bannerad = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            isbottomBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
        }),
        request: const AdRequest());
    bannerad.load();
  }

  void modalBottomSheetMenu2() {
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
                    child: Text('Select from these contacts in your phone',
                        style: TextStyle(
                          color: Colors.green,
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
                    child: Text('They have installed the app',
                        style: TextStyle(
                          color: Color(0xCC385A64),
                          fontFamily: 'Skranji',
                          fontSize: 18,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
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
                          loaded: (contactsWithInstalledApps) {
                            contactsWithApp = contactsWithInstalledApps;
                            if (contactsWithApp.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(
                                  top: 20.0,
                                ),
                                child: Center(
                                  child: Text(
                                      'None of your contacts has installed voice notice',
                                      style: TextStyle(
                                        color: Color(0xCC385A64),
                                        fontFamily: 'Skranji',
                                        fontSize: 14,
                                      )),
                                ),
                              );
                            } else {
                              return ListView(
                                  children: contactsWithInstalledApps
                                      .map(
                                        (user) => SingleContact2(
                                          user: user,
                                        ),
                                      )
                                      .toList());
                            }
                          },
                          error: (String message) => Center(
                                child: Text(message),
                              ));
                    },
                  ),
                ),
              ],
            ),
          );
        });
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
                          color: Colors.green,
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
                          color: Color(0xCC385A64),
                          fontFamily: 'Skranji',
                          fontSize: 18,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<ContactsWithPermissionCubit,
                      ContactsWithPermissionState>(
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
                          loaded: (contactsWithPermission) {
                            usersWithPermission = contactsWithPermission;
                            if (usersWithPermission!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(
                                  top: 20.0,
                                ),
                                child: Center(
                                  child: Text(
                                      'No contact has given you permission',
                                      style: TextStyle(
                                        color: Color(0xFFBC343E),
                                        fontFamily: 'Skranji',
                                        fontSize: 18,
                                      )),
                                ),
                              );
                            } else {
                              return ListView(
                                  children: contactsWithPermission
                                      .map(
                                        (user) => SingleContact(
                                          user: user,
                                        ),
                                      )
                                      .toList());
                            }
                          },
                          error: (String message) => Center(
                                child: Text(message),
                              ));
                    },
                  ),
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

  void removeItem(int index, recordUrl) async {
    final player = AudioPlayer();

    await player.play(AssetSource('delete.wav'));

    final removedItem = allUserAlarms[index];

    listKey.currentState!.removeItem(
      index,
      (context, animation) => ListItemWidget(
        item: removedItem,
        animation: animation,
        onClicked: () {},
      ),
      duration: const Duration(milliseconds: 500),
    );

    //Check to see if deleting causes empty alamrs
    // ignore: use_build_context_synchronously
    context.read<AllAlarmsCubit>().checkIfAllisDeleted();
    //Remove from local DB
    _alarmHelper.delete(recordUrl);
    //REmove from firebase
    var collection = FirebaseFirestore.instance.collection('alarms');
    var snapshot =
        await collection.where('RecordUrl', isEqualTo: recordUrl).get();
    await snapshot.docs.first.reference.delete();

    // context.read<CreateAlarmsCubit>().getUserCreatedalarms();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AllAlarmsCubit, AllAlarmsState>(
      listener: (context, state) {},
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ContactsWithAppCubit>().getContactsWithApp();
            context.read<ContactsWithoutAppCubit>().getContactsWithoutApp();
          },
          child: Scaffold(
              floatingActionButton: currentIndex == 2
                  ? FloatingActionButton(
                      backgroundColor: Colors.green,
                      onPressed: () {
                        modalBottomSheetMenu2();
                      },
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: SvgPicture.asset('assets/icons/add.svg',
                            color: Colors.white, fit: BoxFit.fitHeight),
                      ),
                    )
                  : FloatingActionButton(
                      backgroundColor: Colors.green,
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
                          child: Image.asset('assets/icons/logoh.png',
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
                          'Instant Voice Notice',
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
                            currentIndex = 3;
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
                          Navigator.of(context).pop();
                          final snackBar = SnackBar(
                            duration: const Duration(seconds: 5),
                            content: const Text(
                              'You sure you want to logout?',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Skranji',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                            action: SnackBarAction(
                              label: 'Proceed',
                              textColor: const Color(0xFF7689D6),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const OnboardingScreen();
                                }));
                              },
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                            child: Icon(Icons.arrow_back, color: Colors.yellow),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 65,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.green,
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
                    TopBanner(userName: userName),
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
                    BlocBuilder<AllAlarmsCubit, AllAlarmsState>(
                      builder: (context, state) {
                        return state.when(
                            initial: () => Column(
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(
                                        child: CircularProgressIndicator(
                                      color: Color(0xCC385A64),
                                      strokeWidth: 5,
                                    )),
                                  ],
                                ),
                            loading: () => Column(
                                  children: const [
                                    SizedBox(height: 100),
                                    Center(
                                        child: CircularProgressIndicator(
                                      color: Color(0xCC385A64),
                                      strokeWidth: 5,
                                    )),
                                  ],
                                ),
                            loaded:
                                (List<dynamic> allAlarms, List allUserNames) {
                              allUserAlarms = allAlarms;

                              if (allUserAlarms.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 250.25,
                                        width: 200.5,
                                        child: Image.asset(
                                          "assets/images/empty.gif",
                                          height: 125.0,
                                          width: 125.0,
                                        ),
                                      ),
                                      const Text('No alarms for you yet',
                                          style: TextStyle(
                                            color: Color(0xCC385A64),
                                            fontFamily: 'Skranji',
                                            fontSize: 18,
                                          )),
                                    ],
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: AnimatedList(
                                      key: listKey,
                                      initialItemCount: allAlarms.length,
                                      itemBuilder: (context, index, animation) {
                                        return ListItemWidget(
                                            item: allAlarms[index],
                                            animation: animation,
                                            name: allUserNames[index],
                                            onClicked: () {
                                              removeItem(
                                                index,
                                                allAlarms[index]['RecordUrl'],
                                              );
                                            });
                                      }),
                                );
                              }
                            },
                            error: (String message) => Center(
                                  child: Text(message),
                                ));
                      },
                    )
                  ],
                ),
                const CreatedAlarms(),
                const InstantVoiceNotice(),
                const ContactsPermissions(),
                const OnboardingScreen(),
              ][currentIndex],
              bottomNavigationBar: isbottomBannerAdLoaded == false
                  ? Container(
                      height: 10,
                      color: Colors.white,
                    )
                  : SizedBox(
                      height: bannerad.size.height.toDouble(),
                      width: bannerad.size.width.toDouble(),
                      child: AdWidget(ad: bannerad))),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class ListItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final Animation<double> animation;
  final VoidCallback? onClicked;
  final String? name;
  const ListItemWidget(
      {Key? key,
      required this.item,
      required this.animation,
      this.onClicked,
      this.name})
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
                                            color: Colors.green,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                            border: Border.all(
                                              color: Colors.black12, width: 4,
                                              // 1.5
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                                widget.name
                                                    .toString()
                                                    .split(" ")[0],
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
                                            Text(widget.item['AlarmTitle'],
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
                                            debugPrint(
                                                "[debug datetime]:  $dateTime");
                                            context
                                                .read<EditTimeCubit>()
                                                .changeTime(
                                                    _time.hour,
                                                    _time.minute,
                                                    widget.item['RecordUrl']);
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
                                      BlocBuilder<EditTimeCubit, EditTimeState>(
                                        builder: (context, state) {
                                          return state.when(
                                              initial: () {
                                                return Text(
                                                    '${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.item['DateTime'].toDate().toString()).minute} ${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour > 12 ? 'PM' : 'AM'}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontFamily: 'Skranji',
                                                      fontSize: 28,
                                                    ));
                                              },
                                              loading: () {
                                                return Text(
                                                    '${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.item['DateTime'].toDate().toString()).minute} ${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour > 12 ? 'PM' : 'AM'}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF7689D6),
                                                      fontFamily: 'Skranji',
                                                      fontSize: 28,
                                                    ));
                                              },
                                              loaded: (hour, minute, fileRef) {
                                                if (fileRef ==
                                                    widget.item['RecordUrl']) {
                                                  return Text(
                                                      '$hour : $minute ${hour > 12 ? 'PM' : 'AM'}',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF7689D6),
                                                        fontFamily: 'Skranji',
                                                        fontSize: 28,
                                                      ));
                                                } else {
                                                  return Text(
                                                      '${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.item['DateTime'].toDate().toString()).minute} ${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour > 12 ? 'PM' : 'AM'}',
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF7689D6),
                                                        fontFamily: 'Skranji',
                                                        fontSize: 28,
                                                      ));
                                                }
                                              },
                                              error: ((message) =>
                                                  Text(message)));
                                        },
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                          DateFormat('EEEE')
                                              .format(DateTime.parse(widget
                                                  .item['DateTime']
                                                  .toDate()
                                                  .toString()))
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
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Row(
                                children: [
                                  Text(
                                      '${widget.name.toString().split(" ")[0]} created this alarm for you',
                                      style: const TextStyle(
                                        color: Color(0xFF385A64),
                                        fontFamily: 'Skranji',
                                        fontSize: 15,
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

class SingleContact2 extends StatelessWidget {
  const SingleContact2({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Contact user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 10.0, right: 50, left: 50, top: 10.0),
      child: OpenContainer(
        closedColor: const Color(0xFFF9F9F9),
        closedElevation: 0,
        transitionDuration: const Duration(seconds: 1),
        openBuilder: (BuildContext context, _) => RecordingPage2(
          contact: user,
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
                            child: Text(user.displayName![0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Skranji',
                                  fontSize: 18,
                                )),
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      Text('${user.displayName}',
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
    required this.userName,
  }) : super(key: key);
  final String userName;

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

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
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, top: 10),
                        child: Text('Top of the ${greeting()}',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30.0, top: 10),
                        child: InkWell(
                          onTap: () {},
                          child: SizedBox(
                            height: 15.0,
                            width: 15.0,
                            child: SvgPicture.asset(
                              'assets/icons/cancel.svg',
                              // color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0, top: 5),
                        child: Text(userName,
                            style: const TextStyle(
                              color: Colors.green,
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
                          height: 70,
                          width: 70,
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
