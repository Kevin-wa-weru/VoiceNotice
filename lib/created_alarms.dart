import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:voicenotice/Cubits/cubit/create_alarms_cubit.dart';
import 'package:voicenotice/Cubits/cubit/edit_time_cubit.dart';
import 'package:voicenotice/homepage.dart';

class CreatedAlarms extends StatefulWidget {
  const CreatedAlarms({Key? key}) : super(key: key);

  @override
  State<CreatedAlarms> createState() => _CreatedAlarmsState();
}

class _CreatedAlarmsState extends State<CreatedAlarms> {
  late List<dynamic>? allCreatedAlarms = [];
  final listKey = GlobalKey<AnimatedListState>();

  Future removeItem(
      int index, recordUrl, targetUserid, creatorPhone, targetUserName) async {
    var targetuserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(targetUserid)
        .get();

    List userWithPermissionPhones = targetuserData.data()!['canDelete'];

    if (userWithPermissionPhones.isEmpty) {
      return false;
    }

    print(userWithPermissionPhones);
    if (userWithPermissionPhones.contains(creatorPhone) == false) {
      return false;
    }

    if (userWithPermissionPhones.contains(creatorPhone) == true) {
      final player = AudioPlayer();

      await player.play(AssetSource('delete.wav'));

      final removedItem = allCreatedAlarms![index];

      listKey.currentState!.removeItem(
        index,
        (context, animation) => ListOfItemWidget(
          item: removedItem,
          animation: animation,
          onClicked: () {},
        ),
        duration: const Duration(milliseconds: 500),
      );

      var collection = FirebaseFirestore.instance.collection('alarms');
      var snapshot =
          await collection.where('RecordUrl', isEqualTo: recordUrl).get();
      await snapshot.docs.first.reference.delete();
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<CreateAlarmsCubit>().getUserCreatedalarms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          const TopBanner(),
          BlocBuilder<CreateAlarmsCubit, CreateAlarmsState>(
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
                  loaded: (List<dynamic> allAlarms) {
                    allCreatedAlarms = allAlarms;

                    if (allCreatedAlarms!.isEmpty) {
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
                            const Text('Its Empty here...',
                                style: TextStyle(
                                  color: Color(0xFF7689D6),
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
                              return ListOfItemWidget(
                                  item: allAlarms[index],
                                  animation: animation,
                                  onClicked: () async {
                                    var response = await removeItem(
                                      index,
                                      allAlarms[index]['RecordUrl'],
                                      allAlarms[index]['TargetUserid'],
                                      allAlarms[index]['createdByPhoneNUmber'],
                                      allAlarms[index]['createdForUserName'],
                                    );

                                    if (response == false) {
                                      var snackBar = SnackBar(
                                          content: Text(
                                        'Oops.${allAlarms[index]['createdForUserName']} has not given you pemission to delete',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Skranji',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ));
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } else {
                                      var snackBar = const SnackBar(
                                          content: Text(
                                        'Deleted',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Skranji',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ));
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
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
    );
  }
}

// ignore: must_be_immutable
class ListOfItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final Animation<double> animation;
  final VoidCallback? onClicked;
  const ListOfItemWidget(
      {Key? key, required this.item, required this.animation, this.onClicked})
      : super(key: key);

  @override
  State<ListOfItemWidget> createState() => _ListOfItemWidgetState();
}

class _ListOfItemWidgetState extends State<ListOfItemWidget> {
  TimeOfDay _time = TimeOfDay.now().replacing(hour: 11, minute: 30);

  bool iosStyle = true;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  resolveIfCanEditAlarm(
      recordUrl, targetUserid, creatorPhone, targetUserName) async {
    var targetuserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(targetUserid)
        .get();

    List userWithPermissionPhones = targetuserData.data()!['canEdit'];

    if (userWithPermissionPhones.isEmpty) {
      return false;
    }

    if (userWithPermissionPhones.contains(creatorPhone) == false) {
      return false;
    }

    if (userWithPermissionPhones.contains(creatorPhone) == true) {
      return true;
    }
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
                                            child: Text(
                                                widget
                                                    .item['createdForUserName'],
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
                                              (DateTime dateTime) async {
                                            print(dateTime);
                                            debugPrint(
                                                "[debug datetime]:  $dateTime");
                                            var response =
                                                resolveIfCanEditAlarm(
                                                    widget.item['RecordUrl'],
                                                    widget.item['TargetUserid'],
                                                    widget.item[
                                                        'createdByPhoneNUmber'],
                                                    widget.item[
                                                        'createdForUserName']);
                                            if (response == false) {
                                              var snackBar = SnackBar(
                                                  content: Text(
                                                'Oops.${widget.item['createdForUserName']} has not given you pemission to edit',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Skranji',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18),
                                              ));
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            } else {
                                              context
                                                  .read<EditTimeCubit>()
                                                  .changeTime(
                                                      _time.hour,
                                                      _time.minute,
                                                      widget.item['RecordUrl']);
                                            }
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
                                                      color: Color(0xFF7689D6),
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
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Row(
                                children: [
                                  Text(
                                      'YOu created this alarm for ${widget.item['createdForUserName']}',
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
