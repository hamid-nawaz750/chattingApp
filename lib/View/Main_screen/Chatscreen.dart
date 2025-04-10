import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  final String receiverUid;
  final String receiverEmail;

  const Chatscreen({
    super.key,
    required this.receiverUid,
    required this.receiverEmail,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Get current user's UID
  String get myUid => auth.currentUser!.uid;

  /// Generate a unique chat ID
  String get chatId {
    List<String> ids = [myUid, widget.receiverUid];
    ids.sort(); // Ensure both users get the same chat ID
    return ids.join("_");
  }

  /// Function to send a message
  void sendMessage() async {
    final message = messageController.text.trim();
    if (message.isNotEmpty) {
      await firestore
          .collection("Chats")
          .doc(chatId)
          .collection("messages")
          .add({
        'senderUid': myUid,
        'receiverUid': widget.receiverUid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear(); // Clear input field after sending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: SafeArea(
        child: Column(
          children: [
            /// Messages List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection("Chats")
                    .doc(chatId)
                    .collection("messages")
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet"));
                  }

                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index];
                      bool isMe = msg['senderUid'] == myUid;

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            msg['message'],
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// Message Input Field
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Adjust for keyboard
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          hintText: "Type a message...",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: Icon(Icons.send, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
