import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twyshe/classes/chat.dart';
import 'package:twyshe/classes/converation.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/chat.dart';
import 'package:twyshe/utils/assist.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key, required this.title, required this.user});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String user;
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  late TwysheUser _profile;

  @override
  void initState() {
    super.initState();
    _setUser();
  }

  void _setUser() async {
    TwysheUser currentUser = await Assist.getUserProfile();

    setState(() {
      _profile = currentUser;
    });
  }

  ///Adds a new discussion to firestore
  void _startConversation(TwysheChat chat) async {
//TwysheConversation(this.ref, this.user, this.nickname, this.pnPhone, this.posted, this.status, this.posts, this.pnColor, this.pnName);

    TwysheConversation conversation = TwysheConversation(
        chat.id,
        _profile.phone,
        _profile.nickname,
        chat.otherPhone,
        chat.posted,
        chat.status,
        chat.count,
        chat.color,
        chat.otherName);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(conversation: conversation),
      ),
    );
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
            .doc(widget.user)
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

                  String color = data['color'];
                  int count = data['count'] as int;
                  String ref = data['id'];
                  String? message = data['message'];
                  String name = data['name'];
                  String otherName = data['other_name'];
                  String otherPhone = data['other_phone'];
                  String owner = data['owner'];
                  Timestamp timestamp = data['posted'] as Timestamp;
                  int status = data['status'] as int;

                  //TwysheChat(this.color, this.count,  this.id, this.message, this.name, this.otherName, this.otherPhone, this.owner, this.posted, this.status);

                  TwysheChat chat = TwysheChat(color, count, ref, message, name,
                      otherName, otherPhone, owner, timestamp, status);

                  String date =
                      DateFormat('d MMM yy H:m').format(timestamp.toDate());

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                chat.otherName,
                                style: TextStyle(
                                    fontWeight: count != 0
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                date,
                                style: TextStyle(
                                    fontWeight: count != 0
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                  chat.message == null
                                      ? '${chat.name}: (file)'
                                      : '${chat.name}: ${chat.message}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            Expanded(
                              child: count == 0
                                  ? const SizedBox()
                                  : CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        '$count',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.purple,
                            child: Text(
                              otherName.toUpperCase().substring(0, 2),
                              style: const TextStyle(color: Colors.white),
                            )),
                        onTap: () {
                          _startConversation(chat);
                        },
                      ),
                    ),
                  );
                })
                .toList()
                .cast(),
          );
        },
      ),
    );
  }
}
