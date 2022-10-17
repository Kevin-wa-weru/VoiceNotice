import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicenotice/set_name.dart';

enum Status { waiting, error }

class VerifyNumber extends StatefulWidget {
  const VerifyNumber({Key? key, required this.number}) : super(key: key);
  final String number;
  @override
  // ignore: no_logic_in_create_state
  State<VerifyNumber> createState() => _VerifyNumberState(number);
}

class _VerifyNumberState extends State<VerifyNumber> {
  final otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  final String phoneNumber;
  _VerifyNumberState(this.phoneNumber);
  var status = Status.waiting;
  // ignore: prefer_typing_uninitialized_variables
  var verificationID;

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  Future _verifyPhoneNumber() async {
    auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
        debugPrint('Verification sent');
      },
      verificationFailed: (FirebaseAuthException verificationFailed) async {
        debugPrint('Verification has failed');
      },
      codeSent: (verificationId, forceResendingToken) async {
        setState(() {
          verificationID = verificationId;
        });
        debugPrint('CODE::::::::::::::');
        debugPrint(verificationId.toString());
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
  }

  Future _sendCodeToFirebase({String? code}) async {
    if (verificationID != null) {
      var credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: code!);

      await auth
          .signInWithCredential(credential)
          .then((value) async {
            final CollectionReference usersRef =
                FirebaseFirestore.instance.collection("users");

            await usersRef.doc(value.user!.uid).set({
              'userid': value.user!.uid,
              'phone': phoneNumber,
              'canCreate': [phoneNumber],
              'canDelete': [phoneNumber],
              'canEdit': [phoneNumber],
            });

            // ignore: use_build_context_synchronously
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SetName(
                userid: value.user!.uid,
                phoneNumber: phoneNumber,
              );
            }));
          })
          .whenComplete(() {})
          .onError((error, stackTrace) {
            setState(() {
              otpController.text = "";
              status = Status.error;
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: status != Status.error
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text('Verify your phone number',
                        style: TextStyle(
                          color: Color(0xFF385A64),
                          fontFamily: 'Skranji',
                          fontSize: 18,
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text('Enter OTP sent to ${widget.number}',
                        style: const TextStyle(
                          color: Colors.green,
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
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            letterSpacing: 30,
                            fontFamily: 'Skranji',
                            fontWeight: FontWeight.w600),
                        keyboardType: TextInputType.phone,
                        autofillHints: const <String>[
                          AutofillHints.telephoneNumber
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 0.2),
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
                          filled: true,
                          hintStyle: const TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Skranji',
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        onChanged: (value) async {
                          setState(() {});
                          if (value.length == 6) {
                            await _sendCodeToFirebase(code: value);
                          }
                        },
                        controller: otpController,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Center(
                          child: Text('Did not receive OTP?',
                              style: TextStyle(
                                color: Color(0xFF385A64),
                                fontFamily: 'Skranji',
                                fontSize: 18,
                              )),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          await _verifyPhoneNumber();
                        },
                        child: const Center(
                          child: Text('Resend OTP ',
                              style: TextStyle(
                                color: Colors.green,
                                fontFamily: 'Skranji',
                                fontSize: 18,
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text('OTP verification',
                          style: TextStyle(
                            color: Color(0xFF385A64),
                            fontFamily: 'Skranji',
                            fontSize: 18,
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Center(
                      child: Text('OTP used is invalid',
                          style: TextStyle(
                            color: Color(0xFFBC343E),
                            fontFamily: 'Skranji',
                            fontSize: 12,
                          )),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Center(
                        child: Text('Edit  Number',
                            style: TextStyle(
                              color: Colors.green,
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        await _verifyPhoneNumber();
                        setState(() {
                          status = Status.waiting;
                        });
                      },
                      child: const Center(
                        child: Text('Resend Code',
                            style: TextStyle(
                              color: Color(0xFF7689D6),
                              fontFamily: 'Skranji',
                              fontSize: 18,
                            )),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
