// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voicenotice/homepage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 2;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF7689D6) : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  height: 600.0,
                  color: Colors.white,
                  child: PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Column(
                        children: [
                          Container(
                            color: Colors.white,
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 0,
                                ),
                                Column(
                                  children: const [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text('VOICE NOTICE',
                                        style: TextStyle(
                                          color: Color(0xFFBC343E),
                                          fontFamily: 'Skranji',
                                          fontSize: 30,
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Send voice notes as alarms',
                                        style: TextStyle(
                                          color: Color(0xFF7689D6),
                                          fontFamily: 'Skranji',
                                          fontSize: 15,
                                        )),
                                    SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 105.25,
                                  width: 100.5,
                                  child: SvgPicture.asset(
                                      'assets/images/img5.svg',
                                      fit: BoxFit.fitHeight),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            // color: Colors.red,
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 50,
                                ),
                                SizedBox(
                                  height: 250.25,
                                  width: 200.5,
                                  child: SvgPicture.asset(
                                      'assets/images/img9.svg',
                                      fit: BoxFit.fitHeight),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                // color: Colors.red,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Text('Alarms just became fun',
                                            style: TextStyle(
                                              color: Color(0xFF7689D6),
                                              fontFamily: 'Skranji',
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: const [
                                        SizedBox(
                                          width: 70,
                                        ),
                                        Text('Record your voice',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontFamily: 'Skranji',
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: const [
                                        SizedBox(
                                          width: 90,
                                        ),
                                        Text('Set is as alarm for friend',
                                            style: TextStyle(
                                              color: Color(0xFFBC343E),
                                              fontFamily: 'Skranji',
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  // color: Colors.red,
                                  height:
                                      MediaQuery.of(context).size.height * 0.2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 50.0),
                                    child: SizedBox(
                                      height: 90.25,
                                      width: 50.5,
                                      child: SvgPicture.asset(
                                          'assets/images/img6.svg',
                                          fit: BoxFit.fitHeight),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            color: Colors.white,
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text('VOICE NOTICE',
                                          style: TextStyle(
                                            color: Color(0xFFBC343E),
                                            fontFamily: 'Skranji',
                                            fontSize: 30,
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                          'Set an alarm for your friends',
                                          style: TextStyle(
                                            color: Color(0xFF7689D6),
                                            fontFamily: 'Skranji',
                                            fontSize: 15,
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: const [
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 20.0),
                                            child: Text(
                                                'Using custom recorded voices',
                                                style: TextStyle(
                                                  color: Color(0xFF7689D6),
                                                  fontFamily: 'Skranji',
                                                  fontSize: 15,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: SizedBox(
                                    height: 105.25,
                                    width: 100.5,
                                    child: SvgPicture.asset(
                                        'assets/images/img13.svg',
                                        fit: BoxFit.fitWidth),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            // color: Colors.red,
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 50,
                                ),
                                SizedBox(
                                  height: 250.25,
                                  width: 200.5,
                                  child: Image.asset(
                                    "assets/images/gif1.gif",
                                    height: 125.0,
                                    width: 125.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 400,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextFormField(
                                style: const TextStyle(
                                    fontFamily: 'Skranji',
                                    fontWeight: FontWeight.w600),
                                keyboardType: TextInputType.name,
                                decoration: InputDecoration(
                                  fillColor: Colors.white60,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                        color: Colors.transparent, width: 0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFF7689D6), width: 0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xFF7689D6), width: 2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      height: 6,
                                      width: 6,
                                      child: SvgPicture.asset(
                                          'assets/icons/phone.svg',
                                          height: 6,
                                          color: Colors.black,
                                          fit: BoxFit.fitHeight),
                                    ),
                                  ),
                                  filled: true,
                                  hintText: 'Phone number',
                                  hintStyle: const TextStyle(
                                      color: Colors.black54,
                                      fontFamily: 'Skranji',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                                controller: phoneController,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return HomePage();
                              }));
                            },
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xFF7689D6),
                              ),
                              child: const Center(
                                child: Text('Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Skranji',
                                      fontSize: 15,
                                    )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages - 1
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: InkWell(
                              onTap: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                              child: Container(
                                height: 40,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFF7689D6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Skranji',
                                          fontSize: 15,
                                        )),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    SizedBox(
                                      height: 15.00,
                                      width: 30.5,
                                      child: SvgPicture.asset(
                                          'assets/icons/forward_arrow.svg',
                                          color: Colors.white,
                                          height: 6,
                                          fit: BoxFit.fitHeight),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Text(''),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
