import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/discussion.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/screens/discussion.dart';
import 'package:twyshe/utils/assist.dart';

class PeersPage extends StatefulWidget {
  final TwysheUser twysheUser;

  const PeersPage({super.key, required this.twysheUser});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<PeersPage> createState() => _PeersPageState();
}

class _PeersPageState extends State<PeersPage> {
  // Setting reference to 'tasks' collection
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection(Assist.firestoreAppCode)
      .doc(Assist.firestoreUsersKey)
      .collection(Assist.firestoreUsersKey)
      .where('type', isEqualTo: Assist.userPeer)
      .orderBy('name', descending: false)
      .snapshots();

  @override
  void initState() {
    super.initState();

    _setUser();
  }

  void _setUser() async {
    Assist.updateUserStatus(twysheUser: widget.twysheUser, typing: false);
  }

  ///Adds a new discussion to firestore
  void _startConversation(String pnPhone, pnColor, pnName) async {
    String? conversationId =
        Assist.getCoversationId(widget.twysheUser.phone, pnPhone);

    if (conversationId == null) {
      //same phone number
      Assist.showSnackBar(context, 'Sorry! But you cannot chat with yourself!');
    } else {
      //start conversation
      Assist.log(
          'Starting conversation for user ${widget.twysheUser.phone} and peer navigator $pnPhone and $conversationId computed id');

      TwysheConversation conversation = TwysheConversation(
          conversationId,
          widget.twysheUser.phone,
          widget.twysheUser.nickname,
          pnPhone,
          Timestamp.now(),
          1,
          0,
          pnColor,
          pnName);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Navigators'),
      ),
      backgroundColor: Colors.purple,
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.active &&
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No peers for now',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  String ref = document.id;

                  String nickname = data['name'];
                  Timestamp timestamp = data['timestamp'] as Timestamp;

                  bool isTyping = data['typing'] as bool;

                  if (data.containsKey('color')) {}
                  if (data.containsKey('color')) {}

                  TwysheUser user = TwysheUser(
                      phone: ref,
                      nickname: nickname,
                      color: Assist.defaultColor,
                      pin: '1234',
                      status: 1);

                  return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          title: Text(user.nickname, maxLines: 4),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ref),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      nickname,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      isTyping
                                          ? 'Typing...'
                                          : Assist.getLastSeen(
                                              timestamp, false),
                                      style:
                                          const TextStyle(color: Colors.purple),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: user.color == ''
                                  ? Colors.purple
                                  : Assist.getHexColor(user.color),
                              child: Text(
                                nickname.toUpperCase().substring(0, 2),
                                style: const TextStyle(color: Colors.white),
                              )),
                          onTap: () {
                            _startConversation(ref, user.color, nickname);
                          },
                        ),
                      ));
                })
                .toList()
                .cast(),
          );
        },
      ),
    );
  }
}
