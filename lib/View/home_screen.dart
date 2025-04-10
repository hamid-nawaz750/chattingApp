import 'package:chatting_app/View/Authentication_Screens/SignUp_screen.dart';
import 'package:chatting_app/View/Main_screen/Chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messagecontroller = TextEditingController();

  void sendmessage() async {
    final message = messagecontroller.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance.collection('users').add({
        'message': message,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /////////////////////////
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found.'));
                }

                var users = snapshot.data!.docs
                    .where((doc) => doc['uid'] != myUid)
                    .toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Chatscreen(
                                      receiverUid: user['uid'],
                                      receiverEmail: user['email'],
                                    )));
                      },
                      child: ListTile(
                        title: Text(user['email']),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          ///////////////
        ],
      ),
    );
  }
}
