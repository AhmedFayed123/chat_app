import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageCpntroller = TextEditingController();
  @override
  void dispose() {
    _messageCpntroller.dispose();
  }
  _sendMessage()async{
    final enteredMessage=_messageCpntroller.text;
    if(enteredMessage.trim().isEmpty){
      return;
    }
    _messageCpntroller.clear();
    final user=FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    await FirebaseFirestore.instance.collection('chat')
        .add({
      'text':enteredMessage,
      'createdAt':Timestamp.now(),
      'userId':user.uid,
      'username':userData.data()!['username'],
      'userImage':userData.data()!['image_url'],
    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 15,right: 1,bottom: 15),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                controller: _messageCpntroller,
                autocorrect: true,
                enableSuggestions: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'send a message ....',
                ),
              ),
          ),
          IconButton(onPressed: _sendMessage, icon: Icon(Icons.send),color: Colors.blue,)
        ],
      ),
    );
  }
}
