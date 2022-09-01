import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreatedAlarms extends StatefulWidget {
  const CreatedAlarms({Key? key}) : super(key: key);

  @override
  State<CreatedAlarms> createState() => _CreatedAlarmsState();
}

class _CreatedAlarmsState extends State<CreatedAlarms> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            color: const Color(0xffF9F9F9),
            child: Column(
              children: const [
                SizedBox(
                  height: 40,
                ),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
                SingleCreatedAlarm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SingleCreatedAlarm extends StatefulWidget {
  const SingleCreatedAlarm({
    Key? key,
  }) : super(key: key);

  @override
  State<SingleCreatedAlarm> createState() => _SingleCreatedAlarmState();
}

class _SingleCreatedAlarmState extends State<SingleCreatedAlarm> {
  TimeOfDay _time = TimeOfDay.now().replacing(hour: 11, minute: 30);
  bool iosStyle = true;

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100)),
                                          border: Border.all(
                                            color: Colors.black12, width: 4,
                                            // 1.5
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text('Joy',
                                              style: TextStyle(
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
                                          const Text('WakyWaky',
                                              style: TextStyle(
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
                                        onChangeDateTime: (DateTime dateTime) {
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
                                  children: const [
                                    Text('10:30 PM ',
                                        style: TextStyle(
                                          color: Color(0xFF7689D6),
                                          fontFamily: 'Skranji',
                                          fontSize: 28,
                                        )),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Text('Wednesday ',
                                        style: TextStyle(
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
                              children: const [
                                Text('You created this alarm for Joy',
                                    style: TextStyle(
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
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: SvgPicture.asset('assets/icons/bin.svg',
                                  height: 6,
                                  color: Colors.black,
                                  fit: BoxFit.fitHeight),
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
