import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:voicenotice/homepage.dart';
import 'package:voicenotice/models/user_alarms.dart';
import 'package:voicenotice/services/alarm_helper.dart';

class CreatedAlarms extends StatefulWidget {
  const CreatedAlarms({Key? key}) : super(key: key);

  @override
  State<CreatedAlarms> createState() => _CreatedAlarmsState();
}

class _CreatedAlarmsState extends State<CreatedAlarms> {
  late List<dynamic>? allAlarms = [];
  final listKey = GlobalKey<AnimatedListState>();

  Future<List> loadAlarms() async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';
    var response = await FirebaseFirestore.instance
        .collection("alarms")
        .where('CreateByUserID', isEqualTo: testUser)
        .get();

    List alarms = response.docs;

    for (var alarms in alarms) {
      allAlarms!.add(alarms.data());
    }
    return alarms;
  }

  void removeItem(
      int index, recordUrl, targetUserid, creatorPhone, targetUserName) async {
    String testUser = 'RBlD6eB8zVPhPvxz1czJkxi44Es1';

    var targetuserData = await FirebaseFirestore.instance
        .collection("users")
        .doc(targetUserid)
        .get();

    List userWithPermissionPhones = targetuserData.data()!['canDelete'];
    print(userWithPermissionPhones);
    if (userWithPermissionPhones.contains(creatorPhone)) {
      var snackBar = SnackBar(
          content: Text(
        'Oops.$targetUserName has not given you pemission to delete ',
        style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Skranji',
            fontWeight: FontWeight.w500,
            fontSize: 18),
      ));
    } else {
      final player = AudioPlayer();

      await player.play(AssetSource('delete.wav'));

      final removedItem = allAlarms![index];

      // allUserAlarms.removeAt(index);
      listKey.currentState!.removeItem(
        index,
        (context, animation) => ListItemWidget(
          item: removedItem,
          animation: animation,
          onClicked: () {},
        ),
        duration: const Duration(milliseconds: 500),
      );

      //REmove from firebase
      var collection = FirebaseFirestore.instance.collection('alarms');
      var snapshot =
          await collection.where('RecordUrl', isEqualTo: recordUrl).get();
      await snapshot.docs.first.reference.delete();
    }
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
          FutureBuilder<List>(
              future: loadAlarms(),
              builder: (context, snapshot) {
                if (allAlarms!.isEmpty) {
                  return Center(
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
                        const Text('You have not yet created an alarm !',
                            style: TextStyle(
                              color: Color(0xCC385A64),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text('Tap button below to add',
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
                        initialItemCount: snapshot.data!.length,
                        itemBuilder: (context, index, animation) {
                          return ListItemWidget(
                              item: {
                                'AlarmTitle': snapshot.data![index]
                                    ['AlarmTitle'],
                                'CreateByUserID': snapshot.data![index]
                                    ['CreateByUserID'],
                                'DateTime': snapshot.data![index]['DateTime'],
                                'RecordUrl': snapshot.data![index]['RecordUrl'],
                                'TargetUserid': snapshot.data![index]
                                    ['TargetUserid'],
                                'createdByUserName': snapshot.data![index]
                                    ['createdByUserName'],
                                'createdByPhoneNUmber': snapshot.data![index]
                                    ['createdByPhoneNUmber'],
                              },
                              animation: animation,
                              onClicked: () {
                                removeItem(
                                  index,
                                  snapshot.data![index]['RecordUrl'],
                                  snapshot.data![index]['TargetUserid'],
                                  snapshot.data![index]['createdByPhoneNUmber'],
                                  snapshot.data![index]['createdByUserName'],
                                );
                              });
                        }),
                  );
                }
              }),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class ListItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
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
                                            child: Text(
                                                widget
                                                    .item['createdByUserName'],
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
                                          '${DateTime.parse(widget.item['DateTime'].toDate().toString()).hour} : ${DateTime.parse(widget.item['DateTime'].toDate().toString()).minute}',
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
                                      'You created this for ${widget.item['createdByUserName']}',
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
