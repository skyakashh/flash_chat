import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ChatScreen extends StatefulWidget {
  static const id='Chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final msgController=TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth=FirebaseAuth.instance;
  late var lguser = FirebaseAuth.instance.currentUser;
  String msg="",mail="";

  void initstate(){
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      setState(() {
        lguser = user;
      });
    }
  }

  void msgstream() async{
    await for (var snap in _firestore.collection('messages').snapshots()  )
      {
          for(var message in snap.docs)
            {
                print(message.data());
            }
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                // _auth.signOut();
                // Navigator.pop(context);
                //getmessages();
                msgstream();
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder <QuerySnapshot>  (
                stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final messages = snapshot.data!.docs;
                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    final msgText = message.get('text');
                    final msgSender = message.get('sender');
                    final msgWidget = Mesgbubble(sender: msgSender, text: msgText,mail: lguser!.email,);
                    messageWidgets.add(msgWidget);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                      children: messageWidgets,
                    ),
                  );
                } else {
                  // Handle the case when there is no data
                  return Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent,),);
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      onChanged: (value) {
                        //Do something with the user input.
                        msg=value;

                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      msgController.clear();
                      _firestore.collection('messages').add({
                        'text': msg,
                        'sender': lguser?.email,
                      });
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Mesgbubble extends StatelessWidget {

  Mesgbubble({this.sender,this.text,this.mail});

  final String? sender;
  final String? text;
  final String? mail;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: (mail==sender) ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
        Text('$sender',style: TextStyle(
        fontSize: 12.0,
        color: Colors.white,
        ),
        ),
        Material(
          borderRadius: (mail==sender) ?
          BorderRadius.only(topRight:Radius.circular(30.0) ,bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0) ):
          BorderRadius.only(topLeft:Radius.circular(30.0) ,bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0),),
          color: (mail==sender) ? Colors.lightGreen :Colors.lightBlueAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
            child: Text('$text',
              style: TextStyle(
                fontSize: 15.0,

              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}