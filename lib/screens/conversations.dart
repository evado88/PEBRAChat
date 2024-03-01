import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/discussion.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/discussion.dart';
import 'package:twyshe/utils/assist.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late final TwysheUser _currentUser;

  @override
  void initState() {
    super.initState();
    _setUser();
  }

  void _setUser() async {
    _currentUser = await Assist.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(Assist.firestoreAppCode)
            .doc(Assist.firestoreConversationsKey)
            .collection(Assist.firestoreConversationsKey)
            .doc(_currentUser.phone)
            .collection(Assist.firestoreConversationsKey)
            .orderBy('posted', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  int count = data['count'] as int;
                  String ref = document.id;

                  String message = data['message'];
                  String name = data['name'];
                  String owner = data['owner'];
                  Timestamp timestamp = data['posted'] as Timestamp;
                  String recipient = data['recipient'];
                  int status = data['status'] as int;

              

                  TwysheConversation conversation = TwysheConversation(
                      ref,
                      count,
                      message,
                      name,
                      owner,
                      timestamp,
                      recipient,
                      status);

                  String date =
                      DateFormat('d MMM yyy H:m').format(timestamp.toDate());

                  return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          title: Text(conversation.name),
                          subtitle: Text(conversation.message.isEmpty
                              ? '(no message)'
                              : '${conversation.message} • $date'),
                          leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.purple,
                              child: Text(
                                name.toUpperCase().substring(0, 2),
                                style: const TextStyle(color: Colors.white),
                              )),
                          onTap: () {

/*
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiscussionPage(discussion: discussion),
                              ),
                            );*/

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
