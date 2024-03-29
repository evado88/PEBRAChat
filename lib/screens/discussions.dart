import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twyshe/classes/discussion.dart';
import 'package:twyshe/classes/user.dart';
import 'package:twyshe/screens/add_discussion.dart';
import 'package:twyshe/screens/discussion.dart';
import 'package:twyshe/utils/assist.dart';

class DiscussionsPage extends StatefulWidget {
  const DiscussionsPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<DiscussionsPage> createState() => _DiscussionsPageState();
}

class _DiscussionsPageState extends State<DiscussionsPage> {
  // Setting reference to 'tasks' collection
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection(Assist.firestoreAppCode)
      .doc(Assist.firestoreDiscussionsKey)
      .collection(Assist.firestoreDiscussionsKey)
      .where('status', isEqualTo: Assist.messageStateActive)
      .orderBy('posted', descending: true)
      .snapshots();

  @override
  void initState() {
    super.initState();

    _setUser();
  }

  void _setUser() async {
    TwysheUser currentUser = await Assist.getUserProfile();

    Assist.updateUserStatus(twysheUser: currentUser, typing: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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

          return ListView(
            children: snapshot.data!.docs
                .map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  String ref = document.id;

                  String title = data['title'];
                  String description = data['description'];

                  String phone = data['user'];
                  String nickname = data['nickname'];
                  String color = data['color'];

                  int posts = data['posts'] as int;
                  Timestamp timestamp = data['posted'] as Timestamp;
                  String typing = '';

                  if (data.containsKey('typing')) {
                    typing = data['typing'];
                  }

                  TwysheDiscussion discussion = TwysheDiscussion(
                      ref,
                      title,
                      description,
                      phone,
                      nickname,
                      color,
                      posts,
                      timestamp,
                      typing);

                  String date =
                      DateFormat('d MMM yyy H:m').format(timestamp.toDate());

                  return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          title: Text(discussion.title, maxLines: 4),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(typing == '' ? date : '$typing is typing...',
                                  style: typing == ''
                                      ? null
                                      : const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
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
                                      posts == 0 ? 'No Posts' : '$posts Posts',
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
                              backgroundColor: discussion.color == ''
                                  ? Colors.purple
                                  : Assist.getHexColor(discussion.color),
                              child: Text(
                                nickname.toUpperCase().substring(0, 2),
                                style: const TextStyle(color: Colors.white),
                              )),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiscussionPage(discussion: discussion),
                              ),
                            );
                          },
                        ),
                      ));
                })
                .toList()
                .cast(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (() {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const AddDiscussionPage(title: 'Add Discussion'),
            ),
          );
        }),
        tooltip: 'Add Discussion',
        child: const Icon(Icons.add),
      ),
    );
  }
}
