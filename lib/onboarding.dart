// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voicenotice/services/country_codes.dart';
import 'package:voicenotice/verifynumber.dart';

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
  bool keyboardVisible = false;
  final phoneController = TextEditingController();

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

  String? countryName = '';
  String? countryCode = '';
  Future<String> getCountry() async {
    Network n = Network("http://ip-api.com/json");
    var locationSTR = (await n.getData());
    var locationx = jsonDecode(locationSTR);

    List<Country> country = countryList
        .where((element) => element.name == locationx["country"])
        .toList();
    setState(() {
      countryName = locationx["country"];
      countryCode = '+${country.first.phoneCode}';
    });
    debugPrint('COUNTRYYYYY:::::::::::::: $countryCode');
    return locationx["country"];
  }

  @override
  void initState() {
    super.initState();
    getCountry();
  }

  @override
  Widget build(BuildContext context) {
    keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    // CountryDetails details = CountryCodes.detailsForLocale();
    // Locale locale = CountryCodes.getDeviceLocale()!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
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
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            color: Colors.transparent,
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Column(
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: SizedBox(
                                    height: 105.25,
                                    width: 100.5,
                                    child: SvgPicture.asset(
                                        'assets/images/img5.svg',
                                        fit: BoxFit.fitHeight),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.transparent,
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Column(
                                  children: [
                                    Row(
                                      children: const [
                                        SizedBox(
                                          width: 30,
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
                                          width: 50,
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
                                          width: 70,
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
                          const SizedBox(
                            height: 100,
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20.0),
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
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              color: Colors.transparent,
                              height: 150,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            const Center(
                              child: Text('Enter your phone number',
                                  style: TextStyle(
                                    color: Color(0xFF385A64),
                                    fontFamily: 'Skranji',
                                    fontSize: 18,
                                  )),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextFormField(
                                  // textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Skranji',
                                      fontSize: 18,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600),
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    fillColor: const Color(0xFFF5F5F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(25),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent,
                                          width: 0.2),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 2),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15,
                                          top: 12,
                                          bottom: 15,
                                          right: 2),
                                      child: Text(
                                        countryCode!,
                                        style: const TextStyle(
                                            color: Colors.black54,
                                            fontFamily: 'Skranji',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18),
                                      ),
                                    ),
                                    filled: true,
                                    hintText: 'Phone number',
                                    hintStyle: const TextStyle(
                                        color: Colors.black54,
                                        fontFamily: 'Skranji',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
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
                                // AlarmHelper _alarmHelper = AlarmHelper();
                                // _alarmHelper.insertUserName(
                                //     UserName(idi: 1, userID: 'Herooo'));
                                if (phoneController.text.isEmpty ||
                                    phoneController.text.length < 8 ||
                                    phoneController.text.length > 12) {
                                  var snackBar = const SnackBar(
                                      content: Text(
                                    'Provide a valid phone',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Skranji',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } else {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return VerifyNumber(
                                      number:
                                          '$countryCode${phoneController.text.trim()}',
                                    );
                                  }));
                                }
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
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // _currentPage != _numPages - 1
                //     ?
                //     : Container(),
              ],
            ),
            keyboardVisible
                ? Container()
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120.0, left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
