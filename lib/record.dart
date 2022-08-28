import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecordingPage extends StatefulWidget {
  const RecordingPage({Key? key}) : super(key: key);

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage> {
  int currentIndex = 0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  fontSize: 30,
                )),
            // const SizedBox(
            //   width: 8,
            // ),
            // SvgPicture.asset(
            //   "assets/icons/recorder.svg",
            //   height: 23,
            //   width: 23,
            // ),
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
                    currentIndex = 3;
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
                onTap: () {},
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
              const Text(
                'Permissions',
                style: TextStyle(
                  color: Color(0xCC385A64),
                  fontFamily: 'Skranji',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 45,
              ),
              const Text(
                'Log Out',
                style: TextStyle(
                  color: Color(0xCC385A64),
                  fontFamily: 'Skranji',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
                      'Voic Notice v1.0.1',
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
      body: Column(
        children: [
          const TopBanner(),
          Container(
            height: 40,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF7689D6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.00,
                  width: 30.5,
                  child: SvgPicture.asset('assets/icons/microphone.svg',
                      color: Colors.white, height: 6, fit: BoxFit.fitHeight),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text('Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Skranji',
                      fontSize: 15,
                    )),
              ],
            ),
          ),
        ],
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
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: MediaQuery.of(context).size.width - 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(140),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
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
                              color: Colors.transparent,
                              height: 60,
                              width: 200,
                              child: Column(
                                children: [
                                  const Text('You are creating a new',
                                      style: TextStyle(
                                        color: Color(0xCC385A64),
                                        fontFamily: 'Skranji',
                                        fontSize: 18,
                                      )),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Row(
                                      children: const [
                                        Text('voice notice for Peter',
                                            style: TextStyle(
                                              color: Color(0xCC385A64),
                                              fontFamily: 'Skranji',
                                              fontSize: 18,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          color: Colors.white,
                          height: 80,
                          width: 100,
                          child: Image.asset(
                            "assets/images/gif1.gif",
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
