import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:voicenotice/homepage.dart';

class SetName extends StatefulWidget {
  const SetName({Key? key, this.userid, this.phoneNumber}) : super(key: key);
  final String? userid;
  final String? phoneNumber;
  @override
  State<SetName> createState() => _SetNameState();
}

class _SetNameState extends State<SetName> {
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text('Hello There, Set a new username',
                style: TextStyle(
                  color: Color(0xFF385A64),
                  fontFamily: 'Skranji',
                  fontSize: 18,
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(
            child: Text('Enter Your username',
                style: TextStyle(
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Skranji', fontWeight: FontWeight.w600),
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.transparent, width: 2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  filled: true,
                  hintText: 'Username',
                  hintStyle: const TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Skranji',
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
                onChanged: (value) async {
                  setState(() {});
                },
                controller: nameController,
              ),
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () async {
              if (nameController.text.isEmpty) {
                var snackBar = const SnackBar(
                    content: Text(
                  'Provide a username',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Skranji',
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else if (nameController.text.length > 8) {
                var snackBar = const SnackBar(
                    content: Text(
                  'Should not be more then 8 words',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Skranji',
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                //update username in authenticated users
                FirebaseAuth.instance.currentUser!
                    .updateDisplayName(nameController.text);

                //update firebase doc to add username
                final CollectionReference usersRef =
                    FirebaseFirestore.instance.collection("users");

                await usersRef
                    .doc(widget.userid)
                    .update({'userName': nameController.text});

                //route to homepage
                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const HomePage();
                }));
              }
            },
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green,
              ),
              child: const Center(
                child: Text('Proceed to Voice Notice',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Skranji',
                      fontSize: 18,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
